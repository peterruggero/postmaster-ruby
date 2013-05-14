module Postmaster

  class Rates < APIResource
  
    def self.get(params={})
      response = Postmaster.request(:post, '/v1/rates', params)
      self.construct_from(response)
    end
  end
  
end
