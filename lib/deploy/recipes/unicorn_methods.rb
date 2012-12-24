module Deploy
  module Recipes
    module UnicornMethods

      def self.included(base)
        base.class_eval do

          desc :unicorn_start, "Start unicorn" do
            remote "sudo /etc/init.d/#{dep_config.unicorn_script} start"
          end

          desc :unicorn_stop, "Stop unicorn" do
            remote "sudo /etc/init.d/#{dep_config.unicorn_script} stop"
          end

          desc :unicorn_restart, "Restart unicorn" do
            remote "sudo /etc/init.d/#{dep_config.unicorn_script} restart"
          end

          desc :unicorn_upgrade, "Reload code and restart workers" do
            remote "sudo /etc/init.d/#{dep_config.unicorn_script} upgrade"
          end

          #   namespace :unicorn do

          #     desc "Setup unicorn config for nginx and as an init file"
          #     task :setup_config do
          #       sudo "ln -nfs #{current_path}/config/deploy/nginx/unicorn_nginx_#{composite_name} /etc/nginx/sites-enabled/"
          #       sudo "ln -nfs #{current_path}/config/deploy/unicorn/unicorn_init_#{composite_name} /etc/init.d/"
          #     end

          #     desc "Create nginx conf file"
          #     task :create_config_nginx do
          #       template = "#{File.dirname(__FILE__)}/deploy/templates/nginx/unicorn_nginx.erb"
          #       filename = "#{File.dirname(__FILE__)}/deploy/nginx/unicorn_nginx_#{composite_name}"
          #       options  = {
          #         :composite_name => composite_name,
          #         :server_name    => server_name,
          #       }

          #       create_conf_file(template, filename, options)
          #     end

          #     desc "Create unicorn conf file"
          #     task :create_config_unicorn do
          #       template = "#{File.dirname(__FILE__)}/deploy/templates/unicorn/unicorn_conf.erb"
          #       filename = "#{File.dirname(__FILE__)}/deploy/unicorn/unicorn_conf_#{composite_name}.rb"
          #       options  = {
          #         :composite_name => composite_name,
          #         :app_root       => current_path,
          #       }

          #       create_conf_file(template, filename, options)
          #     end

          #     desc "Create init script file"
          #     task :create_config_unicorn_init do
          #       template = "#{File.dirname(__FILE__)}/deploy/templates/unicorn/unicorn_init.erb"
          #       filename = "#{File.dirname(__FILE__)}/deploy/unicorn/unicorn_init_#{composite_name}"
          #       options  = {
          #         :composite_name => composite_name,
          #         :app_root       => current_path,
          #         :app_user       => group,
          #         :app_env        => rails_env,
          #       }

          #       create_conf_file(template, filename, options)
          #       system "chmod 775 #{filename}"
          #     end

          #   end # namespace :unicorn

          # end

          # def composite_name
          #  "suitepad-#{ENV['RAILS_ENV']}"
          # end

          # def create_conf_file(template, output, options)
          #   require 'erubis'

          #   nginx_conf     = File.read(template)
          #   nginx_erb_conf = Erubis::Eruby.new(nginx_conf)

          #   filename = output

          #   File.open(output, 'w') do |file|
          #     file.write(nginx_erb_conf.result(options))
          #   end
          # end

        end
      end

    end
  end
end

