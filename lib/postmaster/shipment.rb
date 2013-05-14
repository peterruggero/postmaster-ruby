module Postmaster
  
  class Shipment < APIResource
    include Postmaster::APIOperations::List
    
    def self.create(params={})
      Util.normalize_address(params[:to])
      Util.normalize_address(params[:from])
      response = Postmaster.request(:post, self.url, params)
      self.construct_from(response)
    end
    
    def track
      response = Postmaster.request(:get, url('track'))
      if response[:results].nil?
        return nil
      end
      response[:results].map { |i| Postmaster::Tracking.construct_from(i) }
    end
    
    def void
      response = Postmaster.request(:post, url('void'))
      refresh_from({})
      response[:message] == 'OK'
    end
  end
end
