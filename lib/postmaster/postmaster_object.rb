module Postmaster
  class PostmasterObject
    include Enumerable
   
    # The default :id method is deprecated and isn't useful to us
    if method_defined?(:id)
      undef :id
    end

    def initialize(id=nil)
      @values = {}
      # This really belongs in APIResource, but not putting it there allows us
      # to have a unified inspect method
      @unsaved_values = Set.new
      @transient_values = Set.new
      self.id = id if id
    end

    def self.construct_from(values)
      obj = self.new(values[:id])
      obj.refresh_from(values)
      obj
    end

    def to_s(*args)
      Postmaster::JSON.dump(@values, :pretty => true)
    end

    def inspect()
      id_string = (self.respond_to?(:id) && !self.id.nil?) ? " id=#{self.id}" : ""
      "#<#{self.class}:0x#{self.object_id.to_s(16)}#{id_string}> JSON: " + Postmaster::JSON.dump(@values, :pretty => true)
    end

    def refresh_from(values)
      # which keys should be converted to Postmaster_Objects
      obj_keys = {
        'Postmaster::Shipment.to' => Postmaster::Address,
        'Postmaster::Shipment.from' => Postmaster::Address,
        'Postmaster::Shipment.package' => Postmaster::Package,
        'Postmaster::AddressProposal.address' => Postmaster::Address,
        'Postmaster::Tracking.last_update' => 'DateTime',
        'Postmaster::TrackingHistory.timestamp' => 'DateTime',
        'Postmaster::TransitTime.delivery_timestamp' => 'DateTime'
      }
  
      # which keys should be converted to list of Postmaster_Objects
      obj_list_keys = {
        'Postmaster::AddressValidation.addresses' => Postmaster::Address,
        'Postmaster::Shipment.packages' => Postmaster::Package,
        'Postmaster::Tracking.history' => Postmaster::TrackingHistory
      }
        
      removed = Set.new(@values.keys - values.keys)
      added = Set.new(values.keys - @values.keys)
      # Wipe old state before setting new.  This is useful for e.g. updating a
      # customer, where there is no persistent card parameter.  Mark those values
      # which don't persist as transient

      instance_eval do
        remove_accessors(removed)
        add_accessors(added)
      end
      removed.each do |k|
        @values.delete(k)
      end
      values.each do |k, v|
        full_key = self.class.name + "." + k.to_s
        if obj_keys.has_key?(full_key)
          klass = obj_keys[full_key]
          if klass == 'DateTime'
            @values[k] = DateTime.strptime(v.to_s, '%s')
          else
            @values[k] = klass.construct_from(v)
          end
        elsif obj_list_keys.has_key?(full_key)
          klass = obj_list_keys[full_key]
          @values[k] = []
          v.each do |i|
            @values[k].push(klass.construct_from(i))
          end
        else
          @values[k] = v
        end
      end
    end

    def [](k)
      k = k.to_sym if k.kind_of?(String)
      @values[k]
    end

    def []=(k, v)
      k = k.to_sym if k.kind_of?(String)
      send(:"#{k}=", v)
    end

    def has_key?(k)
      k = k.to_sym if k.kind_of?(String)
      @values.has_key?(k)
    end
    
    def delete(k)
      k = k.to_sym if k.kind_of?(String)
      @values.delete(k)
      remove_accessors([k])
    end
    
    def keys
      @values.keys
    end

    def values
      @values.values
    end

    def to_json(*a)
      Postmaster::JSON.dump(@values)
    end

    def to_hash
      result = @values.clone
      result.each do |k, v|
        if v.kind_of? Postmaster::PostmasterObject
          result[k] = v.to_hash
        elsif v.kind_of? Array and v[0].kind_of? Postmaster::PostmasterObject
          result[k] = v.map { |i| i.to_hash }
        end
      end
      result
    end

    def each(&blk)
      @values.each(&blk)
    end

    protected

    def metaclass
      class << self; self; end
    end

    def remove_accessors(keys)
      metaclass.instance_eval do
        keys.each do |k|
          k_eq = :"#{k}="
          remove_method(k) if method_defined?(k)
          remove_method(k_eq) if method_defined?(k_eq)
        end
      end
    end

    def add_accessors(keys)
      metaclass.instance_eval do
        keys.each do |k|
          k_eq = :"#{k}="
          define_method(k) { @values[k] }
          define_method(k_eq) do |v|
            @values[k] = v
          end
        end
      end
    end

    def method_missing(name, *args)
      if name.to_s.end_with?('=')
        attr = name.to_s[0...-1].to_sym
        @values[attr] = args[0]
        add_accessors([attr])
        return
      else
        return @values[name] if @values.has_key?(name)
      end

      super
    end
  end
end
