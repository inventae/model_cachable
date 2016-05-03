module ModelCachable
  module Save

    def save_in_remote( attributes )
      attributes = remove_id(attributes)
      ModelCachable.configuration.transport.post("#{ self.class.queue_url }", attributes)
    end

    def save_in_repo( attributes )
      attributes = remove_id(attributes)
      self.repo.save( attributes )
    end

    def save
      if self.repo.nil?
        save_in_remote( self.attributes )
      else
        save_in_repo( self.attributes )
      end
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
