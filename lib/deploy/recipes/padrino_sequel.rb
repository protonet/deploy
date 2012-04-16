module Deploy
  module Recipes
    class PadrinoSequel < ::Deploy::Base

      include ::Deploy::Common

      desc "setup_db", "", true do
      end

      desc "migrate_up", "Trys to migrate the database to the current state. Won't destroy any data", true do
        remote "cd #{dep_config.get(:current_path)}"
        remote "bundle exec padrino rake sq:migrate:up -e #{dep_config.get(:env)}"
      end

    end
  end
end

