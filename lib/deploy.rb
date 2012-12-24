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

require 'deploy/recipes/padrino_data_mapper'
require 'deploy/recipes/protonet'
require 'deploy/recipes/git_methods'
require 'deploy/recipes/nginx_methods'
require 'deploy/recipes/passenger_methods'
require 'deploy/recipes/unicorn_methods'
require 'deploy/recipes/ruby_methods'
require 'deploy/recipes/rails_methods'
require 'deploy/recipes/rails_data_mapper_methods'

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