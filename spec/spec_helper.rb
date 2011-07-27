require "deploy"
require 'bacon'

puts APP_ROOT
puts VIRTUAL_APP_ROOT

class Bacon::Context

  def not_real_recipes
    @not_real_recipes ||= ["common.rb", "base.rb"]
  end

  def recipes
    {
      :padrino_data_mapper => [
        :setup, :deploy_create,
        :deploy_push, :deploy_pull,
        :get_and_pack_code,
        :push_code, :get_release_tag,
        :link, :unpack,
        :bundle, :setup_db,
        :auto_migrate, :auto_upgrade,
        :clean_up, :restart,
      ],
      :rails_data_mapper => [
        :setup, :deploy_create,
        :deploy_push, :deploy_pull,
        :get_and_pack_code,
        :push_code, :get_release_tag,
        :link, :unpack,
        :bundle, :setup_db,
        :auto_migrate, :auto_upgrade,
        :clean_up, :restart,
      ]
    }
  end

end

# Bacon.extend(Bacon.const_get("KnockOutput"))
Bacon.extend(Bacon.const_get("TestUnitOutput"))
Bacon.summary_on_exit

