require "postmaster"

# at startup set API key
Postmaster.api_key = "example-api-key"

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

# if address is ok you can ask for time and rates for it
result = Postmaster::TransitTimes.get(
    :from_zip => "78701",
    :to_zip => "78704",
    :weight => 1.5,
    :carrier => "fedex"
)
#puts result.inspect

result = Postmaster::Rates.get(
    :from_zip => "78701",
    :to_zip => "78704",
    :weight => 1.5,
    :carrier => "fedex"
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

# list all created shipments
result = Postmaster::Shipment.all()
#puts result.inspect

# list 3 newest shipments
result = Postmaster::Shipment.all(:limit => 3)
#puts result.inspect

# monitor external package
result = Postmaster::Tracking.monitor_external(
    :tracking_no => "1ZW470V80310800043",
    :url => "http://example.com/your-http-post-listener"
)
#puts result.inspect

# create box example
result = Postmaster::Package.create(
    :width => 10,
    :height => 12,
    :length => 8,
    :name => 'My Box'
)
#puts result.inspect

# list boxes example
result = Postmaster::Package.all(
    :limit => 2
)
#puts result.inspect

# fit items in box example
result = Postmaster::Package.fit(
  "items" =>
    [{"width" => 2.2, "length" => 3, "height" => 1, "count" => 2}],
  "packages" => [
    {"width" => 6, "length" => 6, "height" => 6, "sku" => "123ABC"},
    {"width" => 12, "length" => 12, "height" => 12, "sku" => "456XYZ"}
  ]
)
#puts result.inspect