module Deploy
  module Methods
    module Unicorn

      def self.included(base)
        base.class_eval do

          task :unicorn_start, "Start unicorn" do
            remote "sudo /etc/init.d/#{dep_config.unicorn_script} start"
          end

          task :unicorn_stop, "Stop unicorn" do
            remote "sudo /etc/init.d/#{dep_config.unicorn_script} stop"
          end

          task :unicorn_restart, "Restart unicorn" do
            remote "sudo /etc/init.d/#{dep_config.unicorn_script} restart"
          end

          task :unicorn_upgrade, "Reload code and restart workers" do
            remote "sudo /etc/init.d/#{dep_config.unicorn_script} upgrade"
          end

          def self.create_conf_file(template, output, options)
            require 'erubis'

            nginx_conf     = File.read(template)
            nginx_erb_conf = Erubis::Eruby.new(nginx_conf)

            filename = output

            File.open(output, 'w') do |file|
              file.write(nginx_erb_conf.result(options))
            end
          end

          task :unicorn_setup_config, "Setup unicorn config for nginx and as an init file" do
            sudo "ln -nfs #{dep_config.app_root}/config/deploy/nginx/unicorn_nginx_#{dep_config.composite_name} /etc/nginx/sites-enabled/"
            sudo "ln -nfs #{dep_config.app_root}/config/deploy/unicorn/unicorn_init_#{dep_config.composite_name} /etc/init.d/"
          end

          task :create_config_nginx, "Create nginx conf file" do
            require_params(:server_name)

            template = "#{APP_ROOT}/lib/deploy/templates/nginx/unicorn_nginx.erb"
            filename = "#{VIRTUAL_APP_ROOT}/config/deploy/nginx/unicorn_nginx_#{dep_config.composite_name}"

            options  = {
              :composite_name => dep_config.composite_name,
              :server_name    => dep_config.server_name,
            }

            create_conf_file(template, filename, options)
          end

          task :create_config_unicorn, "Create unicorn conf file" do
            template = "#{APP_ROOT}/lib/deploy/templates/unicorn/unicorn_conf.erb"
            filename = "#{VIRTUAL_APP_ROOT}/config/deploy/unicorn/unicorn_conf_#{dep_config.composite_name}.rb"

            options  = {
              :composite_name => composite_name,
              :app_root       => dep_config.app_root,
            }

            create_conf_file(template, filename, options)
          end

          task :create_config_unicorn_init, "Create init script file" do
            template = "#{APP_ROOT}/lib/deploy/templates/unicorn/unicorn_init.erb"
            filename = "#{VIRTUAL_APP_ROOT}/config/deploy/unicorn/unicorn_init_#{composite_name}"

            options  = {
              :composite_name => dep_config.composite_name,
              :app_root       => dep_config.app_root,
              :app_user       => dep_config.remote_group,
              :app_env        => dep_config.env,
            }

            create_conf_file(template, filename, options)
            system "chmod 775 #{filename}"
          end

        end
      end

    end
  end
end

