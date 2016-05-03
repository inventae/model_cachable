module ModelCachable
  module Save

    def save_in_remote( attributes )
      attributes = remove_id(attributes)
      resource = ModelCachable.configuration.transport.post("#{ self.class.queue_url }", attributes)
      self.id = resource[:id]
    end

    def save_in_repo( attributes )
      attributes = remove_id(attributes)
      obj_from_repo = self.repo.save( attributes )
      self.id = obj_from_repo.id
    end

    def save
      if self.repo.nil?
        resource = save_in_remote( self.attributes )
      else
        resource = save_in_repo( self.attributes )
      end

      set_in_cache

      resource
    end

    def set_in_cache
      ModelCachable.configuration.cache.set( self.key + ":#{self.id}", self.attributes )
    end

private
    def remove_id(attributes)
      if attributes[:id].nil?
        attributes.delete(:id)
      end
      attributes
    end
  end
end
