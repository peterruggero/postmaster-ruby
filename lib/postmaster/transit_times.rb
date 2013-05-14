module Postmaster

  class TransitTimes < APIResource
  
    def self.get(params={})
      response = Postmaster.request(:post, '/v1/times', params)
      if response[:services].nil?
        return nil
      end
      response[:services].map { |i| Postmaster::TransitTime.construct_from(i) }
    end
  end

  class TransitTime < APIResource
  end
  
end
