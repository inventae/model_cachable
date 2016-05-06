require "active_record"
require "active_support"

module ActiveRecordExtension
  extend ActiveSupport::Concern

  module ClassMethods
    def find(*args)
      binding.pry
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecordExtension)
