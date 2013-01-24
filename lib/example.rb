require "postmaster"

Postmaster.api_key = "example-api-key"

result = Postmaster::AddressValidation.validate(
  :company => "ASLS",
  :contact => "Joe Smith",
  :line1 => "1110 Someplace Ave.",
  :city => "Austin",
  :state => "TX",
  :zip => "78704",
  :country => "US"
)

result = Postmaster::Shipment.create(
  :to => {
    :company => "ASLS",
    :contact => "Joe Smith",
    :line1 => "1110 Someplace Ave.",
    :city => "Austin",
    :state => "TX",
    :zip_code => "78704",
    :phone_no => "919-720-7941",
    :country => "US"
  },
  :carrier => "ups",
  :service => "2DAY",
  :package => {
    :value => 55,
    :weight => 1.5,
    :length => 10,
    :width => 6,
    :height => 8,
  },
  :reference => "Order # 54321"
)

result = Postmaster::Shipment.retrieve(1)
