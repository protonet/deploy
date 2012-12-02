VIRTUAL_APP_ROOT = "#{File.dirname(File.expand_path(__FILE__))}" unless defined?(VIRTUAL_APP_ROOT)

require "deploy"
require 'bacon'

dep_config.set :env,         'test'
dep_config.set :dry_run,     true

class Bacon::Context

  def not_real_recipes
    @not_real_recipes ||= ["common.rb", "base.rb"]
  end

  def common_methods
    [
      :setup,
      :deploy,
      :setup_db,
      :auto_migrate,
      :auto_upgrade,
      :restart,
    ]
  end

  def recipes
    {
      :rails_active_record => common_methods
    }
  end

end

# Bacon.extend(Bacon.const_get("KnockOutput"))
Bacon.extend(Bacon.const_get("TestUnitOutput"))
Bacon.summary_on_exit

