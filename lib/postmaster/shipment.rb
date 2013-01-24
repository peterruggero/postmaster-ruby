module Postmaster
  
  class Shipment < APIResource
    include Postmaster::APIOperations::Create
    include Postmaster::APIOperations::List
  end
end
