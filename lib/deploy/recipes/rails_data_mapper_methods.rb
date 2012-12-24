module Deploy
  module Recipes
    class RailsDataMapperMethods

      def self.included(base)
        base.class_eval do

          desc :setup_db, "Creates the database" do
            rake "db:create"
          end

          desc :auto_upgrade, "Trys to migrate the database to the current state. Won't destroy any data" do
            rake "db:autoupgrade"
          end

          desc :auto_migrate, "Migrates the database to the current state. This will completely destroy the data that is there" do
            rake "db:automigrate"
          end

        end
      end

    end
  end
end

