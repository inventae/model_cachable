require 'json'
require 'virtus'

require "active_record/list_extension"

require "model_cachable/configuration"
require "model_cachable/find"
require "model_cachable/base"

module ModelCachable
  def initialize
  end

  module ClassMethods
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure(&block)
      yield configuration
    end
  end

  extend ClassMethods
end
