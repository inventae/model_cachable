$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'model_cachable'
require 'pry'
require 'fakeredis'

class Buu
  attr_accessor :id, :name

  def initialize(attributes={})
    attributes.each{|k,v| self.send("#{k}=", v) }
  end

  def attributes(attributes={})
    { id: 1, name: self.name }
  end

  def self.find(id)
    return new
  end

  def self.save(attributes)
    return new(attributes)
  end

end

class ModelCachable::Foo < ModelCachable::Base
  attribute :id, Integer
  attribute :name, String
end
