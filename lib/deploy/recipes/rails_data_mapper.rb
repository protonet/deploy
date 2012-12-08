module Deploy
  module Recipes
    class RailsDataMapper

      def self.included(base)
        base.class_eval do

          desc :setup_db, "Creates the database" do
            remote "cd #{dep_config.app_root}"
            remote "RAILS_ENV=#{dep_config.env} bundle exec rake db:create"
          end

          desc :auto_upgrade, "Trys to migrate the database to the current state. Won't destroy any data" do
            remote "cd #{dep_config.app_root}"
            remote "RAILS_ENV=#{dep_config.env} bundle exec rake db:autoupgrade"
          end

          desc :auto_migrate, "Migrates the database to the current state. This will completely destroy the data that is there" do
            remote "cd #{dep_config.app_root}"
            remote "RAILS_ENV=#{dep_config.env} bundle exec rake db:automigrate"
          end

        end
      end

    end
  end
end

