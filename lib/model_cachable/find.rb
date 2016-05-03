module ModelCachable
  module Find
    def find_repo_or_remote(id)
      if self.repo.nil?
        return ModelCachable.configuration.transport.get("#{ self.queue_url}/#{id}")
      else
        obj_attributes = self.repo.find( id ).attributes
        ModelCachable.configuration.cache.set( self.key + ":#{id}", obj_attributes )
        return obj_attributes
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
  end
end
