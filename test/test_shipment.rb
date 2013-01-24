# -*- coding: utf-8 -*-
require 'test/unit'
require 'postmaster'
require 'shoulda'
require 'mocha'
require 'rest-client'
require 'cgi'
require 'uri'

class TestShipmentRuby < Test::Unit::TestCase
  include Mocha
 
  sample_shipment = {
    :to => {
      :company => "ASLS",
      :contact => "Joe Smith",
      :line1 => "1110 Algarita Ave",
      :city => "Austin",
      :state => "TX",
      :zip_code => "78704-4429",
      :phone_no => "919-720-7941",
      :country => "US"
    },
    :from_ => {
      :company => "ASLS",
      :contact => "Joe Smith",
      :line1 => "1110 Algarita Ave",
      :city => "Austin",
      :state => "TX",
      :zip_code => "78704-4429",
      :phone_no => "919-720-7941",
      :country => "US"
    },
    :carrier => "ups",
    :service => "2DAY",
    :package => {
      :value => 55,
      :weight => 1.5,
      :length => 10,
      :width => 6,
      :height => 8,
    },
    :reference => "Order # 54321"
  }
 
  context "Shipment" do

    should "be created" do
        result = Postmaster::Shipment.create(params=sample_shipment)
        assert(result.instance_of? Postmaster::Shipment)
    end
    
  end
end
