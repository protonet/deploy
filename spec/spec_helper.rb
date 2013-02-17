VIRTUAL_APP_ROOT = "#{File.dirname(File.expand_path(__FILE__))}" unless defined?(VIRTUAL_APP_ROOT)

require 'simplecov'

SimpleCov.start do
  add_filter 'spec'
  add_filter 'vendor'
  add_filter 'config'

  # add_group 'Models',      'app/models'
  # add_group 'Controllers', 'app/controllers'
  # add_group 'Helpers',     'app/helpers'
  # add_group 'Searchers',   'app/searchers'
  add_group 'Libraries',   'lib'
end

SimpleCov.command_name 'Minitest'

require "deploy"
require 'minitest/autorun'
require 'wrong/adapters/minitest'
require 'minitest/pride'
require 'pry'

Wrong.config.alias_assert :confirm, :override => true
Wrong.config.alias_deny   :deny,    :override => true

dep_config.set :env,         'test'
dep_config.set :dry_run,     true

class MiniTest::Spec
  def common_tasks
    [
      :create_directories,
      :precompile_assets,
      :migrate_db,
      :create_db,
      :bundle,
      :load_schema,
      :remove_tmp_cache,
      :remove_assets,
    ]
  end

  def task_bundles
    {
      :rails => common_tasks
    }
  end

  def confirm_raises(&block)
    begin
      block.call
      return false
    rescue Exception => e
      return true
    end
  end

  def deny_raises(&block)
    !confirm_raises(&block)
  end
end