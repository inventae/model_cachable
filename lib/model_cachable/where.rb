module ModelCachable
  module Where
    PREDICATED = [ :cont, :not_cont, :start, :end, :eq, :in, :lt, :gt, :lteq, :gteq ]
    def where(filters={})
      add_scope( filters )
      self
    end
  end
end
