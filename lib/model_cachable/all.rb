module ModelCachable
  module All
    def find_all_in_repo(key)
      repository = self.repo
      scope.each{|k| repository = repository.where( self.repo.arel_table[k] ) }
      obj_attributes = repository.all
      ModelCachable.configuration.cache.set(key, obj_attributes.map(&self.repo.primary_key.to_sym) )
      return obj_attributes.map{|a| a.attributes }
    end

    def find_all_in_remote
      return ModelCachable.configuration.transport.get("#{ self.queue_url}")
    end

    def find_all_repo_or_remote(key)
      if self.repo.nil?
        find_all_in_remote
      else
        find_all_in_repo(key)
      end
    end

    def scope
      @scope ||= []
    end

    def add_scope(filters)
      @scope ||= []
      @scope << filters
    end

    def scope_key
      key_formatted = scope.map{|keys| keys.map{|k,v| k.to_s + '-' + v.to_s } }.flatten.join(':')
      Digest::SHA1.hexdigest("#{key_formatted}:all")
    end

    def all
      key = self.key + ":query:#{scope_key}"
      cache_obj = ModelCachable.configuration.cache.get(key)
      if cache_obj.nil?
        cache_obj = self.find_all_repo_or_remote(key)
      else
        cache_obj = JSON.parse( cache_obj ).map{|a| self.find(a) }
      end
      @scope = []
      cache_obj
    end
  end
end
