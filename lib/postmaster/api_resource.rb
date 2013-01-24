module Postmaster
  class APIResource < PostmasterObject
    def self.class_name
      self.name.split('::')[-1]
    end

    def self.url()
      if self == APIResource
        raise NotImplementedError.new('APIResource is an abstract class.  You should perform actions on its subclasses (Charge, Customer, etc.)')
      end
      "/v1/#{CGI.escape(class_name.downcase)}s"
    end

    def url
      unless id = self['id']
        raise InvalidRequestError.new("Could not determine which URL to request: #{self.class} instance has invalid ID: #{id.inspect}", 'id')
      end
      "#{self.class.url}/#{CGI.escape(id)}"
    end

    def refresh
      response = Postmaster.request(:get, url)
      refresh_from(response)
      self
    end

    def self.retrieve(id)
      instance = self.new(id.to_s)
      instance.refresh
      instance
    end
  end
end
