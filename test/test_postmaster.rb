# -*- coding: utf-8 -*-
require 'test/unit'
require 'postmaster'
require 'shoulda'
require 'mocha'
require 'rest-client'
require 'cgi'
require 'uri'

class TestPostmasterRuby < Test::Unit::TestCase
  include Mocha
  
  context "Util" do
    should "symbolize_names should convert names to symbols" do
      start = {
        'foo' => 'bar',
        'array' => [{ 'foo' => 'bar' }],
        'nested' => {
          1 => 2,
          :symbol => 9,
          'string' => nil
        }
      }
      finish = {
        :foo => 'bar',
        :array => [{ :foo => 'bar' }],
        :nested => {
          1 => 2,
          :symbol => 9,
          :string => nil
        }
      }

      symbolized = Postmaster::Util.symbolize_names(start)
      assert_equal(finish, symbolized)
    end
  end

  context "API Bindings" do
    setup do
      @mock = mock
      Postmaster.mock_rest_client = @mock
    end

    teardown do
      Postmaster.mock_rest_client = nil
    end

    should "creating a new APIResource should not fetch over the network" do
      @mock.expects(:get).never
      c = Postmaster::Shipment.new(123)
    end

    should "creating a new APIResource from a hash should not fetch over the network" do
      @mock.expects(:get).never
      c = Postmaster::Shipment.construct_from({
        :id => 123,
        :param => "value"
      })
    end

    should "not fetch if only accessing id" do
      @mock.expects(:get).never
      c = Postmaster::Shipment.new(123);
      c.id
    end

    should "specifying invalid api credentials should raise an exception" do
      Postmaster.api_key = "invalid"
      response = test_response(test_invalid_api_key_error, 401)
      assert_raises Postmaster::AuthenticationError do
        @mock.expects(:get).once.raises(RestClient::ExceptionWithResponse.new(response, 401))
        Postmaster::Shipment.retrieve(-1)
      end
    end

    should "AuthenticationErrors should have an http status, http body, and JSON body" do
      Postmaster.api_key = "invalid"
      response = test_response(test_invalid_api_key_error, 401)
      begin
        @mock.expects(:get).once.raises(RestClient::ExceptionWithResponse.new(response, 401))
        Postmaster::Shipment.retrieve(-1)
      rescue Postmaster::AuthenticationError => e
        assert_equal(401, e.http_status)
        assert_equal(true, !!e.http_body)
        assert_equal(true, !!e.json_body[:error][:message])
        assert_equal(test_invalid_api_key_error['error']['message'], e.json_body[:error][:message])
        assert_equal('(Status 401) Invalid API Key provided: invalid', e.to_s)
      end
    end
    
    should "raise an exception if objest id is not specified" do
      assert_raises Postmaster::InvalidRequestError do
        Postmaster::Shipment.new().refresh
      end
    end
  end
end
