module Postmaster

  class Address < APIResource
  end

  class AddressProposal < APIResource
  end
  
  class AddressValidation < APIResource
  
    def self.validate(params={})
      response = Postmaster.request(:post, '/v1/validate', params)
      begin
        proposals = response[:addresses][0][:proposals]
      rescue NoMethodError => e
        return
      end
      
      result = []
      proposals.each do |i|
        result.push(Postmaster::AddressProposal.construct_from(i))
      end
      result
    end

  end
end
