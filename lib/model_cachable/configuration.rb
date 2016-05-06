module ModelCachable
  class Configuration
    attr_accessor :repository
    attr_accessor :cache
    attr_accessor :dictionary
    attr_accessor :transport

    def get_klass( klass )
      repo = Object.const_get( get_item(klass)[:repo] )
    rescue NameError => e
      nil
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
