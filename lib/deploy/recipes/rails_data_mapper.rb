module Deploy
  module Recipes
    class RailsDataMapper < ::Deploy::Utils::Base

      include ::Deploy::Utils::Common

      desc "setup_db", "Creates the database"
      def setup_db
        remote "cd #{dep_config.get(:current_path)}"
        remote "bundle exec rake db:create RAILS_ENV=#{dep_config.get(:env)}"
      end

      desc "auto_upgrade", "Trys to migrate the database to the current state. Won't destroy any data"
      def auto_upgrade
        remote "cd #{dep_config.get(:current_path)}"
        remote "bundle exec rake db:autoupgrade RAILS_ENV=#{dep_config.get(:env)}"
      end

      desc "auto_migrate", "Migrates the database to the current state. This will completely destroy the data that is there"
      def auto_migrate
        remote "cd #{dep_config.get(:current_path)}"
        remote "bundle exec rake db:automigrate RAILS_ENV=#{dep_config.get(:env)}"
      end

    end
  end
end

