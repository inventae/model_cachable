module ModelCachable
  class Configuration
    attr_accessor :repository
    attr_accessor :cache
    attr_accessor :dictionary
    attr_accessor :transport

    def initialize(attributes={})
      attributes.each{|k,v| self.send("#{k}=", v) }
    end

    def get_klass( klass )
      repo = Object.const_get( get_item(klass)[:repo] )
    rescue Exception => e
      nil
    end

    def get( url, options={})
      options.merge!({ headers: headers })
      ModelCachable.configuration.transport.get( url, options )
    end

    def headers
      {
        "Cookie" => (Thread.current[:request].try(:cookies) || []).map{|k,v| "#{k}=#{v}" }.join("; "),
        'Content-Type' => 'application/json',
        "Accept" => "application/json"
      }
    end

    def get_queue_url( klass )
      get_item(klass)[:amqp_url]
    end

    def get_cache_key( klass )
      get_item(klass)[:cache_key]
    end

    def get_item( klass )
      item = @dictionary.select{|a| a[:name] == klass.to_s }.first
      if !item.nil?
        return item
      else
        raise ScriptError::NotImplementedError
      end
    end

  end
end
