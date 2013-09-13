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

    should "flatten_params should convert data" do
      start = {
        :foo => 'bar',
        :array => [
           'foo', 
           'bar',
           { :foo => 'bar' }
        ],
        
        :nested => {
          :foo => 'bar',
          :bar => 'foo'
        }
      }
      finish = [
        ["array[2][foo]", "bar"],
        ["array[]", "bar"],
        ["array[]", "foo"],
        ["foo", "bar"],
        ["nested[bar]", "foo"],
        ["nested[foo]", "bar"]
      ]

      flattened = Postmaster::Util.flatten_params(start)
      assert_equal(finish.sort, flattened.sort)
    end
  end
  
  context "PostmasterObject" do
    should "behave like Hash" do
      obj = Postmaster::PostmasterObject.construct_from({
        :param1 => "value1",
        :param2 => "value2",
      })
      
      assert(obj.method_exists?(:param1))
      assert(obj.method_exists?(:param2))
      assert_equal('value1', obj.param1)
      assert_equal('value2', obj.param2)

      assert(obj.has_key?(:param1))
      assert(obj.has_key?(:param2))
      assert_equal('value1', obj[:param1])
      assert_equal('value2', obj[:param2])
      
      assert_equal([:param1, :param2], obj.keys.sort_by {|sym| sym.to_s})
      assert_equal(['value1', 'value2'], obj.values.sort)
    end
    
    should "set and unset accessors" do
      obj = Postmaster::PostmasterObject.new()
      
      assert(!obj.method_exists?(:foo))

      obj[:foo] = 'bar'
      assert(obj.method_exists?(:foo))
      assert_equal('bar', obj.foo)
      
      obj.delete(:foo)
      assert(!obj.method_exists?(:foo))
    end
    
    should "be serializable" do
      obj = Postmaster::PostmasterObject.construct_from({
        :foo => "bar",
      })
      if MultiJson.adapter.to_s == 'MultiJson::Adapters::Yajl'
        expected = "{\n  \"foo\": \"bar\"\n}"
      else
        expected = '{"foo":"bar"}'
      end
      assert_equal(expected, obj.to_s)
      assert_equal('{"foo":"bar"}', obj.to_json)
      assert(obj.inspect.include? 'JSON: '+expected)
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
