module Deploy
  module Recipes
    class PadrinoSequel < ::Deploy::Utils::Base

      include ::Deploy::Utils::Common

      desc "setup_db", "" do
      end

      desc "migrate_up", "Trys to migrate the database to the current state. Won't destroy any data" do
        remote "cd #{dep_config.get(:current_path)}"
        remote "bundle exec padrino rake sq:migrate:up -e #{dep_config.get(:env)}"
      end

      # desc "auto_migrate", "Migrates the database to the current state. This will completely destroy the data that is there" do
      #   remote "cd #{dep_config.get(:current_path)}"
      #   remote "bundle exec padrino rake dm:auto:migrate -e #{dep_config.get(:env)}"
      # end

    end
  end
end

