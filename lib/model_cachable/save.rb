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
      obj = self.repo.new( attributes )
      if obj.save
        return obj.attributes
      else
        return {} # "TODO: ERROR VALIDACAO"
      end
    end

    def save
      if self.repo.nil?
        attributes = save_in_remote( self.attributes )
      else
        attributes = save_in_repo( self.attributes )
        set_in_cache
      end
      self.attributes =  attributes
    end

    def set_in_cache
      ModelCachable.configuration.cache.set( self.key + ":#{self.id}", self.attributes )
    end

  private
    def get_class_name_stringfy
      # binding.pry
      self.class.name.split("::").last.downcase
    end

    def build_params(attributes)
      { get_class_name_stringfy.to_sym => attributes }
    end

    def post(attributes)
      return ModelCachable.configuration.transport.post("#{ self.class.queue_url }", build_params(attributes))
    end

    def put(attributes)
      return ModelCachable.configuration.transport.put("#{ self.class.queue_url }/#{attributes[:id]}", build_params(attributes))
    end

  end
end
