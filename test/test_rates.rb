# -*- coding: utf-8 -*-
require 'test_helper'
require 'test/unit'
require 'postmaster'
require 'rubygems'
require 'shoulda'
require 'mocha'
require 'rest-client'
require 'cgi'
require 'uri'

class TestRatesRuby < Test::Unit::TestCase
  include Mocha
 
  context "Rates" do

    should "return data" do
      result = Postmaster::Rates.get(
        :from_zip => "78701",
        :to_zip => "78704",
        :weight => 1.5,
        :carrier => "fedex"
      )
      
      assert_instance_of(Postmaster::Rates, result);
      assert(result.keys.include?(:currency))
      assert(result.keys.include?(:charge))
      assert(result.keys.include?(:service))
      
      possible_values = ['GROUND', '3DAY', '2DAY', '2DAY_EARLY', '1DAY', '1DAY_EARLY', '1DAY_MORNING']
      assert(possible_values.include?(result[:service]))
    end

  end
end
