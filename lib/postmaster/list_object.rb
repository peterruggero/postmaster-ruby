module Postmaster
  class ListObject < PostmasterObject

    def each(&blk)
      self.data.each(&blk)
    end

    def all(filters={})
      response = Postmaster.request(:get, url, filters)
      Util.convert_to_postmaster_object(response)
    end

  end
end
