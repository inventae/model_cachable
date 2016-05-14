module ModelCachable
  module All
    def find_all_in_repo(key)
      repository = (scope.empty? ? self.repo : self.repo.ransack( Hash[*scope.flatten] ).result)
      obj_attributes = repository.select( self.repo.primary_key.to_sym ).all
      ids = obj_attributes.map(&self.repo.primary_key.to_sym)
      ModelCachable.configuration.cache.set(key, ids )
      return ids
    end

    def find_all_in_remote
      q = (scope.empty? ? {} : { q: Hash[*scope.flatten] })
      ids = ModelCachable.configuration.transport.get("#{self.queue_url}", { query: q })
      return ids
    end

    def find_all_repo_or_remote(key)
      if self.repo.nil?
        find_all_in_remote
      else
        find_all_in_repo(key)
      end
    end

    def unscoped
      @scope = []
      self
    end

    def scope
      @scope ||= []
    end

    def add_scope(filters)
      scope << filters
    end

    def scope_key
      key_formatted = scope.map{|keys| keys.map{|k,v| k.to_s + '-' + v.to_s } }.flatten.join(':')
      Digest::SHA1.hexdigest("#{key_formatted}:all")
    end

    def all
      key = self.key + ":query:#{scope_key}"
      cache_obj = ModelCachable.configuration.cache.get(key)
      if cache_obj.nil?
        ids_obj = self.find_all_repo_or_remote(key)
      else
        ids_obj = JSON.parse( cache_obj )
      end
      scope = []
      ids_obj.map{|a| self.find(a) }
    end
  end
end
