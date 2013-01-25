module Cheddargetter
  class Client
    include HTTParty
    base_uri 'https://cheddargetter.com/xml'

    attr_accessor :username, :password, :product_code, :options_mode
    
    OptionModes = [:customer, :data, :customer_and_data, :no_options]
    
    def initialize(options = {})
      self.username      = options[:username] || options["username"]
      self.password      = options[:password] || options["password"]
      self.product_code  = options[:product_code] || options["product_code"]

      raise(ArgumentError, "No username specified")     unless username
      raise(ArgumentError, "No password specified")     unless password
      raise(ArgumentError, "No product_code specified") unless product_code
    end

    def method_missing(method, *args, &block)
      parts = method.to_s.split('_')
      response = post('/' + [parts.slice!(0, 2).join('/'), parts].flatten.join('-'), args)

      if response.parsed_response["error"] && response.parsed_response["error"]["__content__"] && response.parsed_response["error"]["__content__"] == 'Resource not found'
        raise NoMethodError.new(method.to_s)
      else
        ::Cheddargetter::Response.new(response)
      end
    end

    def post(url, options)
      set_options_mode(options)

      response = self.class.post(
        full_url(url, options), 
        :body => filter_customer_code_key(options), 
        :basic_auth => {:username => username, :password => password}
      )
    end  

    def customers_delete_all
      #whacky url
      response = self.class.post(
        "https://cheddargetter.com/xml/customers/delete-all/confirm/#{Time.now.to_i}/productCode/#{product_code}", 
        :basic_auth => {:username => username, :password => password}
      )
      ::Cheddargetter::Response.new(response)
    end
    
    private
    
    def full_url(url, options = [])
      return_url = url_with_product(url)

      (options.first || {}).each do |name, value|
        return_url += param_from_attribute_name(name, value) || ''
      end unless options_mode == :data
      return_url
    end
    
    def set_options_mode(options)    
      if !options || options.length == 0
        self.options_mode = :no_options
      elsif options.is_a?(Array) && options.size == 2
        self.options_mode = :customer_and_data
      elsif options.first.size == 1
        self.options_mode = :customer
      else
        self.options_mode = :data
      end
    end
    
    def filter_customer_code_key(array)
      return {} if !array || array.length == 0
      hash = (array && array.is_a?(Array) && array.last) || array 
      hash[:code] = hash.delete(:customer_code) if hash[:customer_code]
      hash
    end
    
    def url_with_product(url)
      url + product_param 
    end
    
    def product_param
      "/productCode/#{product_code}"
    end
    
    def param_from_attribute_name(name, value)
      name = 'code' if name.to_sym == :customer_code
      name_parts = name.to_s.split('_')
      if name_parts.length > 1   
        name = name.to_s.split('_').map(&:capitalize).join.tap{|str| str.match(/(^\w)/)}.gsub((/^\w/), $1.downcase)
      end
      "/#{name}/#{value}" if value
    end
    
    def customer_param(customer_code)
      "/code/#{customer_code}" if customer_code 
    end
      
    def item_param(item_code)
      "/itemCode/#{item_code}" if item_code
    end
  end
end
