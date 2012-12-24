module Deploy
  module Recipes
    module NginxMethods

      def self.included(base)
        base.class_eval do

          desc :nginx_restart, "Restart nginx" do
            remote "sudo /etc/init.d/nginx restart"
          end

        end
      end

    end
  end
end

