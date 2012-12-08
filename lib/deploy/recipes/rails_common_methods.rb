module Deploy
  module Recipes
    class RailsCommonMethods < ::Deploy::Base

      include ::Deploy::Recipes::CommonMethods

      desc :setup_db, "Creates the database" do
        remote "cd #{dep_config.app_root}"
        remote "RAILS_ENV=#{dep_config.env} bundle exec rake db:create"
      end

      desc :bundle, "Runs bundle to make sure all the required gems are on the ststem" do
        remote "cd #{dep_config.app_root}"
        remote "RAILS_ENV=#{dep_config.env} bundle install --without test development --deployment"
      end

      def self.rake(command)
        remote "cd #{dep_config.app_root}"
        remote "RAILS_ENV=#{dep_config.env} rake #{command}"
      end

    end
  end
end

