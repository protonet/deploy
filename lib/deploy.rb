require 'rubygems'

require 'optparse'
require 'simple_config'

# Application root
APP_ROOT = "#{File.dirname(File.expand_path(__FILE__))}/.."

# This is set to the directory where deploy is run from
VIRTUAL_APP_ROOT = "#{File.expand_path(File.new(".").path)}" unless defined?(VIRTUAL_APP_ROOT)

$: << "#{APP_ROOT}/lib"

require 'deploy/setup'

require 'deploy/util'
require 'deploy/remote_commands'
require 'deploy/process'
require 'deploy/dsl'
require 'deploy/base'

require 'deploy/methods/padrino_data_mapper'
require 'deploy/methods/git'
require 'deploy/methods/nginx'
require 'deploy/methods/passenger'
require 'deploy/methods/unicorn'
require 'deploy/methods/ruby'
require 'deploy/methods/rails'
require 'deploy/methods/rails_data_mapper'

def dep_config
  SimpleConfig.for(:deploy)
end

def verbose?
  dep_config.verbose
end

def present?(key)
  dep_config.exists?(key) && dep_config.get(key)
end

def require_params(*params)
  found_params = []
  params.each do |param|
    if dep_config.exists?(param)
      found_params << dep_config.get(param)
    else
      raise "No required param found: #{param}"
    end
  end

  found_params
end