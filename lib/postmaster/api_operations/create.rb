module Postmaster
  module APIOperations
    module Create
      module ClassMethods
        def create(params={})
          response = Postmaster.request(:post, self.url, params)
          Util.convert_to_postmaster_object(response)
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
