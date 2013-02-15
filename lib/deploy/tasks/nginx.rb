module Deploy
  module Tasks
    module Nginx

      def self.included(base)
        base.class_eval do

          task :nginx_restart, "Restart nginx" do
            remote "sudo /etc/init.d/nginx restart"
          end

        end
      end

    end
  end
end

