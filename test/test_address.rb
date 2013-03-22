# -*- coding: utf-8 -*-
require 'test/unit'
require 'postmaster'
require 'rubygems'
require 'shoulda'
require 'mocha'
require 'rest-client'
require 'cgi'
require 'uri'

class TestAddressRuby < Test::Unit::TestCase
  include Mocha
 
  sample_address = 
 
  context "Address" do

    should "be valid" do
      result = Postmaster::AddressValidation.validate({
        :company => "Asls",
        :contact => "Joe Smith",
        :line1 => "1110 Algarita Ave",
        :city => "Austin",
        :state => "TX",
        :zip_code => "78704",
        :country => "US",
      })
      
      assert_instance_of(Postmaster::AddressValidation, result);
      assert(result.keys.include?(:status))
      assert_kind_of(Array, result[:addresses])
      assert(!result[:addresses].empty?)
      
      address = result[:addresses][0]
      assert_instance_of(Postmaster::Address, address);
      assert(address.keys.include?(:zip_code))
      assert_equal("78704", address[:zip_code])
    end
    
    should "be invalid" do
      assert_raises Postmaster::InvalidRequestError do
          result = Postmaster::AddressValidation.validate({
            :company => "Asls",
            :contact => "Joe Smith",
            :line1 => "007 Nowhere Ave",
            :city => "Austin",
            :state => "TX",
            :zip_code => "00001",
            :country => "US",
          })
      end
    end
    
  end
end
