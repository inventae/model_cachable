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
    self.send(:attr_accessor, name)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  # Override the save method to prevent exceptions.
  def save(validate = true)
    validate ? valid? : true
  end

  def self.where(options={})
    @scope ||= []
    @scope << options
    self
  end

  def self.map
    2.times.map{|a| yield self.find(a+1) }
  end

  def self.all
    self
  end

  def self.to_sql
    "SELECT * FROM test"
  end

  def attributes
    b = {}
    self.class.columns.map{|k| b[k.name.to_sym] = self.send("#{k.name}") }
    b
  end

  def initialize(attributes={})
    attributes.each{|k,v| self.send("#{k}=", v) }
  end

  # self.abstract_class = true
  establish_connection(adapter: 'sqlite3', database: ':memory:')
end

class Buu < Tableless
  column :id, :integer
  column :name, :string

  def self.find(id)
    self.new(id: id, name: "test")
  end
end

class ModelCachable::Foo < ModelCachable::Base
  attribute :id, Integer
  attribute :name, String
end
