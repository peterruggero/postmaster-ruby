if ENV['coverage'] and RUBY_VERSION >= "1.9"
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start
end

require 'stringio'
require 'test/unit'
require 'postmaster'
require 'mocha'
include Mocha

#monkeypatch request methods
module Postmaster   
  @mock_rest_client = nil

  def self.mock_rest_client=(mock_client)
    @mock_rest_client = mock_client
  end

  def self.api_key
    ENV['PM_API_KEY'] || @@api_key
  end
  
  def self.api_base
    ENV['PM_API_HOST'] || @@api_base
  end
  
  # remeber original execute before monkey-patching it
  class << Postmaster
    alias_method :original_execute_request, :execute_request
  end
    
  def self.execute_request(opts)
    # send calls to mock if it's defined otherwise call real service
    if @mock_rest_client
      get_params = (opts[:headers] || {})[:params]
      post_params = opts[:payload]
      case opts[:method]
        when :get then @mock_rest_client.get opts[:url], get_params, post_params
        when :post then @mock_rest_client.post opts[:url], get_params, post_params
        when :delete then @mock_rest_client.delete opts[:url], get_params, post_params
      end
    else
      original_execute_request(opts)
    end
  end
end

def test_response(body, code=200)
  # When an exception is raised, restclient clobbers method_missing.  Hence we
  # can't just use the stubs interface.
  body = MultiJson.dump(body) if !(body.kind_of? String)
  m = mock
  m.instance_variable_set('@postmaster_values', { :body => body, :code => code })
  def m.body; @postmaster_values[:body]; end
  def m.code; @postmaster_values[:code]; end
  m
end


def test_invalid_api_key_error
  {
    "error" => {
      "type" => "invalid_request_error",
      "message" => "Invalid API Key provided: invalid"
    }
  }
end
