$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'model_cachable'
require 'pry'
require 'fakeredis'

class Buu
  def attributes
    { id: 1, name: "test" }
  end
  
  def self.find(id)
    return new
  end
end

class ModelCachable::Foo < ModelCachable::Base;
  attribute :id, Integer
  attribute :name, String
end
