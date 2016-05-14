$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'model_cachable'
require 'pry'
require 'fakeredis'
require 'active_record'
require 'ransack'
require 'database_cleaner'

require 'factory_girl'
FactoryGirl.definition_file_paths = %w{./factories ./test/factories ./spec/factories}
FactoryGirl.find_definitions

RAILS_ROOT = '.'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
load File.join(RAILS_ROOT, 'spec/support/schema.rb')

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

class Buu < ActiveRecord::Base
  self.table_name = "buus"
  self.primary_key = "id"
end

class ModelCachable::Foo < ModelCachable::Base
  attribute :id, Integer
  attribute :name, String
end
