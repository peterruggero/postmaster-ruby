module Postmaster
  
  class Shipment < APIResource
    include Postmaster::APIOperations::Create
    include Postmaster::APIOperations::List
    
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
