require "deploy"
require 'bacon'

puts APP_ROOT
puts VIRTUAL_APP_ROOT

::Deploy::Config.set :env,         'test'
::Deploy::Config.set :dry_run,     true

class Bacon::Context

  def not_real_recipes
    @not_real_recipes ||= ["common.rb", "base.rb"]
  end

  def common_methods
    [
      :setup,
      :pull_create,
      :push_create,
      :pull_update,
      :push_update,
      :get_and_pack_code,
      :push_code,
      :set_release_tag,
      :link,
      :unpack,
      :bundle,
      :setup_db,
      :auto_migrate,
      :auto_upgrade,
      :clean_up,
      :restart,
      :set_prev_release_tag
    ]
  end

  def recipes
    {
      :padrino_data_mapper => common_methods,
      :rails_data_mapper   => common_methods
    }
  end

end

# Bacon.extend(Bacon.const_get("KnockOutput"))
Bacon.extend(Bacon.const_get("TestUnitOutput"))
Bacon.summary_on_exit

