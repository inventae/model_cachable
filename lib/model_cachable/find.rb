module ModelCachable
  module Find
    def find_in_repo( id )
      obj_attributes = self.repo.find( id ).attributes
      ModelCachable.configuration.cache.set( self.key + ":#{id}", obj_attributes.to_json )
      return obj_attributes
    end

    def find_in_remote(id)
      return ModelCachable.configuration.transport.get("#{ self.queue_url}/#{id}")
    end

    def find_repo_or_remote(id)
      if self.repo.nil?
        find_in_remote( id )
      else
        find_in_repo( id )
      end
    end

    def find(id)
      cache_obj = ModelCachable.configuration.cache.get( self.key + ":#{id}" )
      if cache_obj.nil?
        cache_obj = self.find_repo_or_remote( id )
      else
        cache_obj = JSON.parse( cache_obj )
      end
      self.new( cache_obj )
    end

    def first
      id = if self.repo.nil?
        ModelCachable.configuration.transport.get("#{ self.queue_url}/first")
      else
        self.repo.first.try(:id)
      end
      find(id) unless id.nil?
    end

    def last
      id = if self.repo.nil?
        ModelCachable.configuration.transport.get("#{ self.queue_url}/last")
      else
        self.repo.last.try(:id)
      end
      find(id) unless id.nil?
    end

    def count
      count = if self.repo.nil?
        ModelCachable.configuration.transport.get("#{ self.queue_url}/count")
      else
        self.repo.count
      end
    end
  end
end
