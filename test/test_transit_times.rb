# -*- coding: utf-8 -*-
require 'test_helper'
require 'test/unit'
require 'postmaster'
require 'rubygems'
require 'shoulda'
require 'mocha'
require 'rest-client'
require 'date'
require 'cgi'
require 'uri'

class TestTransitTimesRuby < Test::Unit::TestCase
  include Mocha
 
  context "Transit times" do

    should "be able to get" do
      result = Postmaster::TransitTimes.get(
        :from_zip => "78701",
        :to_zip => "78704",
        :weight => 1.5,
        :carrier => "fedex"
      )
      
      assert_kind_of(Array, result)
      assert(!result.empty?)
      assert_instance_of(Postmaster::TransitTime, result[0])
      assert(result[0].keys.include?(:delivery_timestamp))
      assert(result[0].keys.include?(:service))
      assert_instance_of(DateTime, result[0][:delivery_timestamp])
      
      possible_values = ['GROUND', '3DAY', '2DAY', '2DAY_EARLY', '1DAY', '1DAY_EARLY', '1DAY_MORNING']
      assert(possible_values.include?(result[0][:service]))
    end
    

    
  end
end
