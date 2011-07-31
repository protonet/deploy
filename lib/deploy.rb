# Application root
APP_ROOT = "#{File.dirname(File.expand_path(__FILE__))}/.."

# This is set to the directory where deploy is run from
VIRTUAL_APP_ROOT = "#{File.expand_path(File.new(".").path)}"

$: << "#{APP_ROOT}/lib"

def dep_config
  Deploy::Config
end

def should_i_do_it?
  dep_config.get(:env) != 'test' && !dep_config.get(:dry_run)
end

def verbose?
  dep_config.get(:verbose)
end

require 'rubygems'
#require 'bundler/setup'

require 'optparse'

require 'deploy/config'
require 'deploy/setup'

require 'deploy/utils/string'
require 'deploy/utils/remote_commands'
require 'deploy/utils/base'
require 'deploy/utils/common'
require 'deploy/utils/generator'

