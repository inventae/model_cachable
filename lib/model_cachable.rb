require 'json'
require 'virtus'

require "model_cachable/configuration"
require "model_cachable/find"
require "model_cachable/all"
require "model_cachable/where"
require "model_cachable/save"
require "model_cachable/base"

require 'digest/sha1'

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
