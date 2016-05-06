$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'model_cachable'
require 'pry'
require 'fakeredis'
require 'active_record'

class Tableless < ActiveRecord::Base
  def self.columns
    @columns ||= [];
  end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default,
      sql_type.to_s, null)
  end

  # Override the save method to prevent exceptions.
  def save(validate = true)
    validate ? valid? : true
  end

  self.abstract_class = true
  establish_connection(adapter: 'sqlite3', database: ':memory:')
end

class Buu < Tableless
  column :id, :integer
  column :name, :string

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
    attributes[:id] = 1
    return new(attributes)
  end

end

class ModelCachable::Foo < ModelCachable::Base
  attribute :id, Integer
  attribute :name, String
end
