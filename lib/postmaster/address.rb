module Postmaster

  class Address < APIResource
  end

  class AddressProposal < APIResource
  end
  
  class AddressValidation < APIResource
  
    def self.validate(params={})
      response = Postmaster.request(:post, '/v1/validate', params)
      self.construct_from(response)
    end

  end
end
