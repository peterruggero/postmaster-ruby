module Postmaster
  module Util

    def self.objects_to_ids(h)
      case h
      when APIResource
        h.id
      when Hash
        res = {}
        h.each { |k, v| res[k] = objects_to_ids(v) unless v.nil? }
        res
      when Array
        h.map { |v| objects_to_ids(v) }
      else
        h
      end
    end

    def self.symbolize_names(object)
      case object
      when Hash
        new = {}
        object.each do |key, value|
          key = (key.to_sym rescue key) || key
          new[key] = symbolize_names(value)
        end
        new
      when Array
        object.map { |value| symbolize_names(value) }
      else
        object
      end
    end

    def self.url_encode(key)
      URI.escape(key.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    end

    def self.flatten_params(params, parent_key=nil)
      result = []
      params.each do |key, value|
        calculated_key = parent_key ? "#{parent_key}[#{url_encode(key)}]" : url_encode(key)
        if value.is_a?(Hash)
          result += flatten_params(value, calculated_key)
        elsif value.is_a?(Array)
          result += flatten_params_array(value, calculated_key)
        else
          result << [calculated_key, value]
        end
      end
      result
    end

    def self.flatten_params_array(value, calculated_key)
      result = []
      value.each_with_index do |elem,index|
        calculated_key_with_index = "#{calculated_key}[#{index}]"
        if elem.is_a?(Hash)
          result += flatten_params(elem, calculated_key_with_index)
        elsif elem.is_a?(Array)
          result += flatten_params_array(elem, calculated_key_with_index)
        else
          result << ["#{calculated_key}[]", elem]
        end
      end
      result
    end
    
    def self.normalize_address(params)
      if params != nil && params.has_key?(:address)
        line1, line2, line3 = params.delete(:address)
        params[:line1] = line1 if line1
        params[:line2] = line2 if line2
        params[:line3] = line3 if line3
      end
    end
    
  end
end
