module Postmaster
  module APIOperations
    module Create
      module ClassMethods
        def create(params={})
          response = Postmaster.request(:post, self.url, params)
          self.construct_from(response)
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
