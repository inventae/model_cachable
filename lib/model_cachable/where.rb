module ModelCachable
  module Where
    def where(filters={})
      add_scope( filters )
      self
    end
  end
end
