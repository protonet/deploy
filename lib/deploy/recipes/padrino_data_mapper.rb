module Deploy
  module Recipes
    class PadrinoDataMapper < ::Deploy::Base

      include ::Deploy::Recipes::CommonMethods

      desc :setup_db, "Creates the database" do
        remote "cd #{dep_config..app_root}"
        remote "bundle exec padrino rake dm:create -e #{dep_config.env}"
      end

      desc :auto_upgrade, "Trys to migrate the database to the current state. Won't destroy any data" do
        remote "cd #{dep_config.app_root}"
        remote "bundle exec padrino rake dm:auto:upgrade -e #{dep_config.env}"
      end

      desc :auto_migrate, "Migrates the database to the current state. This will completely destroy the data that is there" do
        remote "cd #{dep_config.app_root}"
        remote "bundle exec padrino rake dm:auto:migrate -e #{dep_config.env}"
      end

    end
  end
end

