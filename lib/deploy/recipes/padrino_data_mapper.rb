module Deploy
  module Recipes
    module PadrinoDataMapper

      def self.included(base)
        base.class_eval do

          task :setup_db, "Creates the database" do
            rake "padrino rake dm:create -e #{dep_config.env}"
          end

          task :auto_upgrade, "Trys to migrate the database to the current state. Won't destroy any data" do
            rake "padrino rake dm:auto:upgrade -e #{dep_config.env}"
          end

          task :auto_migrate, "Migrates the database to the current state. This will completely destroy the data that is there" do
            rake "padrino rake dm:auto:migrate -e #{dep_config.env}"
          end

        end
      end

    end
  end
end

