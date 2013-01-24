module Postmaster
  module APIOperations
    module List
      module ClassMethods
        def all(filters={})
          response = Postmaster.request(:get, url, filters)
          Util.convert_to_postmaster_object(response)
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
