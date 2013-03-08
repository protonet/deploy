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

require 'deploy/tasks/padrino_data_mapper'
require 'deploy/tasks/git'
require 'deploy/tasks/nginx'
require 'deploy/tasks/passenger'
require 'deploy/tasks/unicorn'
require 'deploy/tasks/ruby'
require 'deploy/tasks/rails'
require 'deploy/tasks/rails_data_mapper'

def dep_config
  SimpleConfig.for(:deploy)
end

def verbose?
  dep_config.verbose
end

def config_present?(key)
  dep_config.exists?(key) && dep_config.get(key)
end

def require_params(*params)
  found_params = []
  params.each do |param|
    if dep_config.exists?(param.to_sym)
      found_params << dep_config.get(param)
    else
      raise "No required param found: #{param}"
    end
  end

  found_params.size == 1 ? found_params.first : found_params
end