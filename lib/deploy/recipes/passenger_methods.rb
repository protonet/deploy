module Deploy
  module Recipes
    module PassengerMethods

      def self.included(base)
        base.class_eval do

          task :passenger_restart, "Causes the server to restart for this app" do
            remote "touch #{dep_config.app_root}/tmp/restart.txt"
          end

        end
      end

    end
  end
end

