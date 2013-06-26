module Postmaster

  class Package < APIResource
    include Postmaster::APIOperations::Create
    include Postmaster::APIOperations::List

    def self.fit(params={})
      json_params = Postmaster::JSON.dump(params, :pretty => true)
      headers = {:content_type => 'application/json'}
      Postmaster.request(:post, '/v1/packages/fit', json_params, headers)
    end
  end
end
