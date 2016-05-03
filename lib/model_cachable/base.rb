module ModelCachable
  class Base
    include Virtus.model
    extend ModelCachable::Find

    def self.repo
      ModelCachable.configuration.get_klass( self )
    end

    def self.key
      ModelCachable.configuration.get_cache_key( self )
    end

    def self.queue_url
      ModelCachable.configuration.get_queue_url( self )
    end

    def key
      self.class.key
    end

    def repo
      self.class.repo
    end
  end
end
