module Deploy
  module Recipes
    module RailsMethods

      def self.included(base)
        base.class_eval do

          def self.rake(command)
            cmd = []
            cmd << "cd #{dep_config.app_root}"
            cmd << "RAILS_ENV=#{dep_config.env}"
            cmd << "bundle exec" if present?(:use_bundler)
            cmd << "rake #{command}"
            remote cmd.join(' ')
          end

          task :create_directories, "create the directory structure" do
            mkdir "#{dep_config.app_root}/tmp"
            mkdir "#{dep_config.app_root}/log"
          end

          task :bundle, "Runs bundle to make sure all the required gems are on the ststem" do
            remote "cd #{dep_config.app_root}"

            cmd = []
            cmd << "RAILS_ENV=#{dep_config.env}"
            cmd << "bundle install"
            cmd << "--without test development"
            cmd << "--deployment"

            if dep_config.exists?(:bundle_binstubs) && dep_config.bundle_binstubs
              cmd << "--binstubs"
            end

            remote cmd.join(' ')
          end

          task :precompile_assets, "Compile the assets" do
            rake 'assets:precompile'
          end

          task :migrate_db, "Migrate the database" do
            rake 'db:migrate'
          end

          task :create_db, "Create the database for this environment" do
            rake 'db:create'
          end

          task :load_schema, "Load the schema from the schema file" do
            rake 'db:schema:load'
          end

          task :remove_tmp_cache, "Removes the temp cache" do
            remote "sudo rm -rf  #{dep_config.app_root}/tmp/cache"
          end

          task :remove_assets, "Removes the assets" do
            remote "sudo rm -rf  #{dep_config.app_root}/public/assets/*"
          end

        end
      end

    end
  end
end

