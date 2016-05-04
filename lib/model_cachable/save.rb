module ModelCachable
  module Save


    def save_in_remote( attributes )
      if attributes[:id].nil?
        post(attributes)
      else
        put(attributes)
      end
    end

    def save_in_repo( attributes )
      obj_from_repo = self.repo.save( attributes )
      self.id = obj_from_repo.id
      return obj_from_repo
    end

    def save

      if self.repo.nil?
        resource = save_in_remote( build_params )
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
    def get_class_name_stringfy
      # binding.pry
      self.class.name.split("::").last.downcase
    end

    def build_params
      if self.id.nil?
        {}.merge!( get_class_name_stringfy.to_sym => self.attributes )
      else
        { id: self.id }.merge!( get_class_name_stringfy.to_sym => self.attributes )
      end
    end

    def post(params)
      resource = ModelCachable.configuration.transport.post("#{ self.class.queue_url }", params)
      self.id = resource[:id]
      return
    end

    def put(params)
      return ModelCachable.configuration.transport.put("#{ self.class.queue_url }/#{params[:id]}", params)
    end

  end
end
