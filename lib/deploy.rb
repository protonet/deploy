# Application root
APP_ROOT = "#{File.dirname(File.expand_path(__FILE__))}/.."

# This is set to the directory where deploy is run from
VIRTUAL_APP_ROOT = "#{File.expand_path(File.new(".").path)}" unless defined?(VIRTUAL_APP_ROOT)

$: << "#{APP_ROOT}/lib"

def dep_config
  SimpleConfig.for(:application)
end

def should_i_do_it?
  dep_config.env != 'test' && !dep_config.dry_run
end

def verbose?
  dep_config.verbose
end

require 'rubygems'

require 'optparse'
require 'simple_config'

require 'deploy/setup'

require 'deploy/util'
require 'deploy/remote_commands'
require 'deploy/process'
require 'deploy/dsl'
require 'deploy/common_methods'
require 'deploy/base'

require 'deploy/recipes/rails_active_record'


