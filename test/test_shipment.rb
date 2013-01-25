# -*- coding: utf-8 -*-
require 'test/unit'
require 'postmaster'
require 'rubygems'
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
      assert(result.keys.include?(:status))
      assert_equal("Processing", result[:status])
      assert(result.keys.include?(:package))
      assert(result[:package].instance_of? Postmaster::Package)
      assert(result[:package].keys.include?(:type_))
      assert_equal("CUSTOM", result[:package][:type_])
      assert(result[:to].instance_of? Postmaster::Address)
      assert(result[:from_].instance_of? Postmaster::Address)
    end
    
    should "be the same after retreave" do
      shipment1 = Postmaster::Shipment.create(params=sample_shipment)
      shipment2 = Postmaster::Shipment.retrieve(shipment1.id)
      
      shipment1hash = shipment1.to_hash
      shipment2hash = shipment2.to_hash
      # label_urls can be different, so ignore it during check
      shipment1hash[:packages][0].delete(:label_url)
      shipment2hash[:packages][0].delete(:label_url)
      assert_equal(shipment1hash, shipment2hash)
    end
    
  end
end
