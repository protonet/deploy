require 'fileutils'
require 'erb'

# needs a deploy_config that looks like this:
# set :deploy_root, "/home/protonet"
# set :app_name,    "german-shepherd"
# set :database_name, "dashboard_production"
# set :key, "my-license-key"
# set :max_num_releases, 5

module Deploy
  module Recipes
    class Protonet < ::Deploy::Recipes::Base

      def create_directory(dir_name, permissions = nil)
        FileUtils.mkdir_p dir_name
        FileUtils.chmod permissions, dir_name if permissions
      end

      def latest_deploy
        Dir["#{config.get(:releases_path)}/*"].sort.last
      end

      def monit_command(command = "")
        puts "\nrunning monit command #{command}"
        run_now! "/usr/sbin/monit -c #{config.get(:shared_path)}/config/monit_ptn_node -l #{config.get(:shared_path)}/log/monit.log -p #{config.get(:shared_path)}/pids/monit.pid #{command}"
        sleep 2
      end

      def bundle_cleanup
        "unset RUBYOPT;unset GEM_HOME; unset GEM_PATH; unset BUNDLE_GEMFILE; . /usr/local/rvm/scripts/rvm; rvm use default"
      end

      def setup
        self.class.actions = [
          :prepare_code,
          :bundle,
          :npm_install,
          :setup_db,
          :link_current,
          :deploy_monit,
          :restart_apache,
          :start_first_run_services,
          :load_crontab
        ]
        self.class.run_actions(self)
      end

      def deploy
        self.class.actions = [
          :prepare_code,
          :bundle,
          :npm_install,
          :migrate,
          :clean_up,
          :link_current,
          :restart_app,
          :deploy_monit,
          :load_crontab,
          :restart_services,
          :restart_apache
        ]
        self.class.run_actions(self)
      end

      def deploy_monit
        # variables for erb
        shared_path     = config.get(:shared_path)
        current_path    = config.get(:current_path)
        monit_password  = (1..16).collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join

        File.open("#{config.get(:shared_path)}/config/monit_ptn_node", 'w') do |f|
          f.write(ERB.new(IO.read("#{latest_deploy}/config/monit/monit_ptn_node.erb")).result(binding))
        end

        run_now! "chmod 700 #{config.get(:shared_path)}/config/monit_ptn_node"

        # and restart monit
        monit_command "quit"
        # restarts it
        monit_command
        monit_command "monitor all"
        sleep 2
        monit_command "start all"
      end

      def create_directories
        create_directory "#{config.get(:shared_path)}/log"
        create_directory "#{config.get(:shared_path)}/db"
        create_directory "#{config.get(:shared_path)}/system"
        create_directory "#{config.get(:shared_path)}/config/monit.d"
        create_directory "#{config.get(:shared_path)}/config/hostapd.d"
        create_directory "#{config.get(:shared_path)}/config/dnsmasq.d"
        create_directory "#{config.get(:shared_path)}/config/ifconfig.d"
        create_directory "#{config.get(:shared_path)}/config/protonet.d"
        create_directory "#{config.get(:shared_path)}/externals/screenshots"
        create_directory "#{config.get(:shared_path)}/externals/snapshots"
        create_directory "#{config.get(:shared_path)}/externals/image_proxy"
        create_directory "#{config.get(:shared_path)}/solr/data"
        create_directory "#{config.get(:shared_path)}/files", 0770
        create_directory "#{config.get(:shared_path)}/pids", 0770
        create_directory "#{config.get(:shared_path)}/avatars", 0770
      end

      def link_shared_directories
        FileUtils.rm_rf   "#{latest_deploy}/log"
        FileUtils.rm_rf   "#{latest_deploy}/public/system"
        FileUtils.rm_rf   "#{latest_deploy}/tmp/pids"
        FileUtils.mkdir_p "#{latest_deploy}/public"
        FileUtils.mkdir_p "#{latest_deploy}/tmp"
        FileUtils.ln_s    "#{config.get(:shared_path)}/log",        "#{latest_deploy}/log"
        FileUtils.ln_s    "#{config.get(:shared_path)}/system",     "#{latest_deploy}/public/system"
        FileUtils.ln_s    "#{config.get(:shared_path)}/pids",       "#{latest_deploy}/tmp/pids"
        FileUtils.ln_s    "#{config.get(:shared_path)}/externals",  "#{latest_deploy}/public/externals"
      end


      def setup_db
        success = false
        FileUtils.cd latest_deploy do
          db_exists = run_now!("mysql -u root #{config.get(:database_name)} -e 'show tables;' 2>&1 > /dev/null")
          success = if db_exists
            puts "db already exists, please check your db contents, not recreating the db"
            true
          else
            run_now!("#{bundle_cleanup}; export RAILS_ENV=#{config.get(:env)}; bundle exec rake db:setup --trace")
          end
        end
        puts "db not found, creating: #{ success ? "success!" : "FAIL!"}"
        success
      end

      def prepare_code
        create_directories
        copy_code_from_local_release
        link_shared_directories
        true
      end

      def copy_code_from_local_release
        release_dir
        destination_path = File.join(config.get(:releases_path), Time.now.strftime('%Y%m%d%H%M%S'))
        run_now!("cp -r /tmp/protonet-release-latest/dashboard #{destination_path}")
      end

      def release_dir
        FileUtils.mkdir_p config.get(:releases_path) if !File.exists? config.get(:releases_path)
      end

      def clean_up
        all_releases = Dir["#{config.get(:releases_path)}/*"].sort
        if (num_releases = all_releases.size) >= config.get(:max_num_releases)
          num_to_delete = num_releases - config.get(:max_num_releases)

          num_to_delete.times do
            FileUtils.rm_rf "#{all_releases.delete_at(0)}"
          end
        end
        true
      end

      def bundle
        shared_bundle_path  = File.expand_path('bundle', config.get(:shared_path))
        release_bundle_path = File.expand_path('.bundle', latest_deploy)

        FileUtils.mkdir_p shared_bundle_path
        FileUtils.ln_s shared_bundle_path, release_bundle_path

        FileUtils.cd latest_deploy do
          run_now! "#{bundle_cleanup}; bundle install --path=#{release_bundle_path} --without=test cucumber --local"
        end
      end

      def npm_install
        shared_dir  = File.expand_path('node_modules', config.get(:shared_path))
        release_dir = File.expand_path('node/node_modules', latest_deploy)

        FileUtils.mkdir_p shared_dir
        FileUtils.ln_s shared_dir, release_dir
        FileUtils.cd latest_deploy do
          run_now! "export NODE_ENV='production'; npm install"
        end
      end

      def migrate
        FileUtils.cd latest_deploy do
          run_now! "#{bundle_cleanup}; export RAILS_ENV=#{config.get(:env)}; bundle exec rake db:migrate"
        end
      end

      def link_current
        FileUtils.rm_f config.get(:current_path)
        FileUtils.ln_s latest_deploy, config.get(:current_path)
        true
      end

      # todo: one should be enough
      def restart_apache
        FileUtils.touch "#{config.get(:current_path)}/tmp/restart.txt"
        monit_command "restart apache2"
      end

      def restart_app
        run_now! "touch #{latest_deploy}/restart.txt"
      end

      def restart_services
        monit_command "-g daemons restart all"
      end
      
      def start_first_run_services
        exit_status = false
        FileUtils.cd latest_deploy do
          exit_status = run_now! "#{bundle_cleanup}; export RAILS_ENV=#{config.get(:env)}; bundle exec rails runner \"SystemWifi.reconfigure! if SystemWifi.supported?\""
        end
        exit_status
      end
      
      def load_crontab
        exit_status = false
        FileUtils.cd latest_deploy do
          exit_status = run_now! "#{bundle_cleanup}; export RAILS_ENV=#{config.get(:env)}; script/init/cron update"
        end
        exit_status
      end

    end
  end
end

