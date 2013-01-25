module Postmaster
  module APIOperations
    module List
      module ClassMethods
        def all(filters={})
          response = Postmaster.request(:get, url, filters)
          response[:results].map { |i| self.construct_from(i) }
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
