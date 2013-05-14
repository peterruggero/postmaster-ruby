require "postmaster"

# at startup set API key
Postmaster.api_key = "tt_ODcwMDQ6Y0RzeVBKNXN4WHNSTVptSFhtMDlVMk9MMlJr" #"example-api-key"

# at first validate recipient address
result = Postmaster::AddressValidation.validate(
  :company => "Postmaster Inc.",
  :contact => "Joe Smith",
  :line1 => "701 Brazos St. Suite 1616",
  :city => "Austin",
  :state => "TX",
  :zip => "78701",
  :country => "US"
)
#puts result.inspect

# when user will choose delivery type you create shipment
result = Postmaster::Shipment.create(
  :from => {
    :company => "Postmaster Inc.",
    :contact => "Joe Smith",
    :line1 => "701 Brazos St. Suite 1616",
    :city => "Austin",
    :state => "TX",
    :zip_code => "78701",
    :phone_no => "512-693-4040",
    :country => "US"
  },
  :to => {
    :contact => "Joe Smith",
    :line1 => "701 Brazos St. Suite 1616",
    :city => "Austin",
    :state => "TX",
    :zip_code => "78701",
    :phone_no => "512-693-4040",
    :country => "US"
  },
  :carrier => "fedex",
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
#puts result.inspect

# store in your DB shipment ID for later use
shipment_id = result.id

# anytime you can extract shipment data
shipment = Postmaster::Shipment.retrieve(shipment_id)
#puts shipment.inspect

# or check delivery status
result = shipment.track()
#puts result.inspect

# you can cancel shipment, but only before being picked up by the carrier
result = shipment.void()
#puts result.inspect
