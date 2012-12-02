module Deploy
  module Recipes
    class RailsActiveRecord < ::Deploy::Base

      desc "setup_db", "Creates the database", true do
        remote "cd #{dep_config.app_root}"
        remote "bundle exec rake db:create RAILS_ENV=#{dep_config.env}"
      end

      desc "auto_upgrade", "Trys to migrate the database to the current state. Won't destroy any data", true do
        remote "cd #{dep_config.app_root}"
        remote "bundle exec rake db:autoupgrade RAILS_ENV=#{dep_config.env}"
      end

      desc "auto_migrate", "Migrates the database to the current state. This will completely destroy the data that is there", true do
        remote "cd #{dep_config.app_root}"
        remote "bundle exec rake db:automigrate RAILS_ENV=#{dep_config.env}"
      end

    end
  end
end

