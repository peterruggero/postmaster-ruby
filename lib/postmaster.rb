# Postmaster Ruby bindings
require 'pp'
require 'cgi'
require 'set'
require 'date'
require 'rubygems'
require 'openssl'

gem 'rest-client', '~> 1.4'
require 'rest_client'
require 'multi_json'

# Version
require 'postmaster/version'

# API operations
require 'postmaster/api_operations/create'
require 'postmaster/api_operations/list'

# Resources
require 'postmaster/util'
require 'postmaster/json'
require 'postmaster/postmaster_object'
require 'postmaster/api_resource'

require 'postmaster/address'
require 'postmaster/shipment'
require 'postmaster/package'
require 'postmaster/tracking'
require 'postmaster/transit_times'
require 'postmaster/rates'

# Errors
require 'postmaster/errors/postmaster_error'
require 'postmaster/errors/api_error'
require 'postmaster/errors/api_connection_error'
require 'postmaster/errors/invalid_request_error'
require 'postmaster/errors/authentication_error'
require 'postmaster/errors/permission_error'


module Postmaster
  @@api_key = nil
  @@api_base = 'https://api.postmaster.io'

  def self.api_url(url='')
    self.api_base + url
  end

  def self.api_key=(api_key)
    @@api_key = api_key
  end

  def self.api_key
    @@api_key
  end

  def self.api_base=(api_base)
    @@api_base = api_base
  end

  def self.api_base
    @@api_base
  end

  def self.request(method, url, params={}, headers={})
    api_key = self.api_key
    raise AuthenticationError.new('No API key provided.  (HINT: set your API key using "Postmaster.api_key = <API-KEY>".)') unless api_key

    uname = (@@uname ||= RUBY_PLATFORM =~ /linux|darwin/i ? `uname -a 2>/dev/null`.strip : nil)
    lang_version = "#{RUBY_VERSION} p#{RUBY_PATCHLEVEL} (#{RUBY_RELEASE_DATE})"
    ua = {
      :bindings_version => Postmaster::VERSION,
      :lang => 'ruby',
      :lang_version => lang_version,
      :platform => RUBY_PLATFORM,
      :publisher => 'postmaster',
      :uname => uname
    }

    params = Util.objects_to_ids(params)
    url = self.api_url(url)
    case method.to_s.downcase.to_sym
    when :get, :head, :delete
      # Make params into GET parameters
      if params && params.count > 0
        query_string = Util.flatten_params(params).collect{|key, value| "#{key}=#{Util.url_encode(value)}"}.join('&')
        url += "?#{query_string}"
      end
      payload = nil
    else
      if params.kind_of? String
        payload = params
      else
        payload = Util.flatten_params(params).collect{|(key, value)| "#{key}=#{Util.url_encode(value)}"}.join('&')
      end
    end

    begin
      headers = { :x_postmaster_client_user_agent => Postmaster::JSON.dump(ua) }.merge(headers)
    rescue => e
      headers = {
        :x_postmaster_client_raw_user_agent => ua.inspect,
        :error => "#{e} (#{e.class})"
      }.merge(headers)
    end

    headers = {
      :user_agent => "Postmaster/v1 RubyBindings/#{Postmaster::VERSION}",
      :content_type => 'application/x-www-form-urlencoded'
    }.merge(headers)

    opts = {
      :method => method,
      :url => url,
      :headers => headers,
      :open_timeout => 60,
      :payload => payload,
      :timeout => 80,
      :user => api_key,
      :password => "",
    }

    begin
      response = execute_request(opts)
    rescue SocketError => e
      self.handle_restclient_error(e)
    rescue NoMethodError => e
      # Work around RestClient bug
      if e.message =~ /\WRequestFailed\W/
        e = APIConnectionError.new('Unexpected HTTP response code')
        self.handle_restclient_error(e)
      else
        raise
      end
    rescue RestClient::ExceptionWithResponse => e
      if rcode = e.http_code and rbody = e.http_body
        self.handle_api_error(rcode, rbody)
      else
        self.handle_restclient_error(e)
      end
    rescue RestClient::Exception, Errno::ECONNREFUSED => e
      self.handle_restclient_error(e)
    end

    rbody = response.body
    rcode = response.code
    begin
      # Would use :symbolize_names => true, but apparently there is
      # some library out there that makes symbolize_names not work.
      resp = Postmaster::JSON.load(rbody)
    rescue MultiJson::DecodeError
      raise APIError.new("Invalid response object from API: #{rbody.inspect} (HTTP response code was #{rcode})", rcode, rbody)
    end

    resp = Util.symbolize_names(resp)
    resp
  end

  private

  def self.execute_request(opts)
    RestClient::Request.execute(opts)
  end

  def self.handle_api_error(rcode, rbody)
    begin
      error_obj = Postmaster::JSON.load(rbody)
      error_obj = Util.symbolize_names(error_obj)
      if error_obj.has_key?(:message)
        error = error_obj
      elsif error_obj.has_key?(:error)
        error = error_obj[:error]
      else
        raise PostmasterError.new # escape from parsing
      end
    rescue MultiJson::DecodeError, PostmasterError
      raise APIError.new("Invalid response object from API: #{rbody.inspect} (HTTP response code was #{rcode})", rcode, rbody)
    end

    case rcode
    when 400, 404 then
      raise invalid_request_error(error, rcode, rbody, error_obj)
    when 401
      raise authentication_error(error, rcode, rbody, error_obj)
    when 403
      raise permission_error(error, rcode, rbody, error_obj)
    else
      raise api_error(error, rcode, rbody, error_obj)
    end
  end

  def self.invalid_request_error(error, rcode, rbody, error_obj)
    InvalidRequestError.new(error[:message], error[:param], rcode, rbody, error_obj)
  end

  def self.authentication_error(error, rcode, rbody, error_obj)
    AuthenticationError.new(error[:message], rcode, rbody, error_obj)
  end

  def self.permission_error(error, rcode, rbody, error_obj)
    PermissionError.new(error[:message], error[:param], error[:code], rcode, rbody, error_obj)
  end

  def self.api_error(error, rcode, rbody, error_obj)
    APIError.new(error[:message], rcode, rbody, error_obj)
  end

  def self.handle_restclient_error(e)
    case e
    when RestClient::ServerBrokeConnection, RestClient::RequestTimeout
      message = "Could not connect to Postmaster ($apiBase). Please check your internet connection and try again. If this problem persists, let us know at support@postmaster.io."
    when RestClient::SSLCertificateNotVerified
      message = "Could not verify Postmaster's SSL certificate. If this problem persists, let us know at support@postmaster.io."
    else
      message = "Unexpected error communicating with Postmaster. If this problem persists, let us know at support@postmaster.io."
    end
    message += "\n\n(Network error: #{e.message})"
    raise APIConnectionError.new(message)
  end
end

