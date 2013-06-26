module Postmaster

  class Package < APIResource
    include Postmaster::APIOperations::List

    def self.create(params={})
      response = Postmaster.request(:post, self.url, params)
      response[:id]
    end

    def self.fit(params={})
      json_params = Postmaster::JSON.dump(params, :pretty => true)
      headers = {:content_type => 'application/json'}
      Postmaster.request(:post, '/v1/packages/fit', json_params, headers)
    end
  end
end
