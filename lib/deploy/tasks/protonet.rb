require 'fileutils'
require 'erb'

module Deploy
  module Tasks
    class Protonet

      include ::Deploy::Process
      include ::Deploy::RemoteCommands

      def create_directory(dir_name, permissions = nil)
        FileUtils.mkdir_p dir_name
        FileUtils.chmod permissions, dir_name if permissions
      end

      def latest_deploy
        Dir["#{dep_config.get(:releases_path)}/*"].sort.last
      end

      def monit_command(command = "")
        puts "\nrunning monit command #{command}"
        run_now! "/usr/sbin/monit -c #{dep_config.get(:shared_path)}/config/monit_ptn_node -l #{dep_config.get(:shared_path)}/log/monit.log -p #{dep_config.get(:shared_path)}/pids/monit.pid #{command}"
      end

      def bundle_cleanup
        "unset RUBYOPT;unset GEM_HOME; unset GEM_PATH; unset BUNDLE_GEMFILE"
      end

      def setup
        queue [
          :prepare_code,
          :bundle,
          :setup_db,
          :link_current,
          :deploy_monit,
          :restart_apache,
          :start_first_run_services
        ]
        process_queue
      end

      def deploy
        queue [
          :prepare_code,
          :bundle,
          :migrate,
          # :copy_stage_config,
          :clean_up,
          :link_current,
          :deploy_monit,
          :restart_services,
          :restart_apache,
        ]
        process_queue
      end

      def deploy_monit
        # variables for erb
        shared_path   = dep_config.get(:shared_path)
        current_path  = dep_config.app_root

        File.open("#{dep_config.get(:shared_path)}/config/monit_ptn_node", 'w') do |f|
          f.write(ERB.new(IO.read("#{latest_deploy}/config/monit/monit_ptn_node.erb")).result(binding))
        end

        run_now! "chmod 700 #{dep_config.get(:shared_path)}/config/monit_ptn_node"

        # and restart monit
        monit_command "quit"
        sleep 2
        # restarts it
        monit_command
        sleep 2
        monit_command "monitor all"
        monit_command "start all"
      end

      # todo: replace by app configuration & remove
      def copy_stage_config
        run "if [ -f #{release_path}/config/stage_configs/#{stage}.rb ]; then cp #{release_path}/config/stage_configs/#{stage}.rb #{release_path}/config/environments/stage.rb; fi"
      end

      def create_directories
        create_directory "#{dep_config.get(:shared_path)}/log"
        create_directory "#{dep_config.get(:shared_path)}/db"
        create_directory "#{dep_config.get(:shared_path)}/system"
        create_directory "#{dep_config.get(:shared_path)}/config/monit.d"
        create_directory "#{dep_config.get(:shared_path)}/config/hostapd.d"
        create_directory "#{dep_config.get(:shared_path)}/config/dnsmasq.d"
        create_directory "#{dep_config.get(:shared_path)}/config/ifconfig.d"
        create_directory "#{dep_config.get(:shared_path)}/config/protonet.d"
        create_directory "#{dep_config.get(:shared_path)}/externals/screenshots"
        create_directory "#{dep_config.get(:shared_path)}/externals/snapshots"
        create_directory "#{dep_config.get(:shared_path)}/externals/image_proxy"
        create_directory "#{dep_config.get(:shared_path)}/solr/data"
        create_directory "#{dep_config.get(:shared_path)}/user-files", 0770
        create_directory "#{dep_config.get(:shared_path)}/pids", 0770
        create_directory "#{dep_config.get(:shared_path)}/avatars", 0770
      end

      def link_shared_directories
        FileUtils.rm_rf   "#{latest_deploy}/log"
        FileUtils.rm_rf   "#{latest_deploy}/public/system"
        FileUtils.rm_rf   "#{latest_deploy}/tmp/pids"
        FileUtils.mkdir_p "#{latest_deploy}/public"
        FileUtils.mkdir_p "#{latest_deploy}/tmp"
        FileUtils.ln_s    "#{dep_config.get(:shared_path)}/log",        "#{latest_deploy}/log"
        FileUtils.ln_s    "#{dep_config.get(:shared_path)}/system",     "#{latest_deploy}/public/system"
        FileUtils.ln_s    "#{dep_config.get(:shared_path)}/pids",       "#{latest_deploy}/tmp/pids"
        FileUtils.ln_s    "#{dep_config.get(:shared_path)}/externals",  "#{latest_deploy}/public/externals"
      end


      def setup_db
        FileUtils.cd latest_deploy do
          db_exists = run_now!("mysql -u root #{dep_config.get(:database_name)} -e 'show tables;' 2>&1 > /dev/null")
          if !db_exists
            puts "db not found, creating: #{ run_now!("#{bundle_cleanup}; export RAILS_ENV=#{dep_config.get(:env)}; bundle exec rake db:setup") ? "success!" : "FAIL!"}"
          end
        end
      end

      def prepare_code
        create_directories
        get_code_and_unpack
        link_shared_directories
      end

      def get_code_and_unpack
        FileUtils.cd "/tmp"
        run_now! "rm -f /tmp/dashboard.tar.gz"
        release = "/#{ENV["RELEASE_VERSION"]}" if ENV["RELEASE_VERSION"]
        run_now!("wget http://releases.protonet.info/release/get/#{dep_config.get(:key)}#{release} -O dashboard.tar.gz") && unpack
      end

      def release_dir
        FileUtils.mkdir_p dep_config.get(:releases_path) if !File.exists? dep_config.get(:releases_path)
      end

      def unpack
        release_dir
        if File.exists?("/tmp/dashboard.tar.gz")
          FileUtils.cd "/tmp"
          FileUtils.rm_rf "/tmp/dashboard"
          run_now! "tar -xzf #{"/tmp/dashboard.tar.gz"}"
          release_timestamp = "#{dep_config.get(:releases_path)}/#{Time.now.strftime('%Y%m%d%H%M%S')}"
          FileUtils.mkdir_p release_timestamp
          run_now! "mv /tmp/dashboard/* #{release_timestamp}"
        end
      end

      def clean_up
        all_releases = Dir["#{dep_config.get(:releases_path)}/*"].sort
        if (num_releases = all_releases.size) >= dep_config.get(:max_num_releases)
          num_to_delete = num_releases - dep_config.get(:max_num_releases)

          num_to_delete.times do
            FileUtils.rm_rf "#{all_releases.delete_at(0)}"
          end
        end
      end

      def bundle
        shared_dir  = File.expand_path('bundle', dep_config.get(:shared_path))
        release_dir = File.expand_path('.bundle', latest_deploy)

        FileUtils.mkdir_p shared_dir
        FileUtils.ln_s shared_dir, release_dir

        FileUtils.cd latest_deploy

        run_now! "#{bundle_cleanup}; bundle install --path=#{release_dir} --without=test cucumber --local"
      end

      def migrate
        FileUtils.cd latest_deploy
        run_now! "#{bundle_cleanup}; export RAILS_ENV=#{dep_config.get(:env)}; bundle exec rake db:migrate"
      end

      def link_current
        FileUtils.rm_f dep_config.app_root
        FileUtils.ln_s latest_deploy, dep_config.app_root
      end

      # todo: one should be enough
      def restart_apache
        FileUtils.touch "#{dep_config.app_root}/tmp/restart.txt"
        monit_command "restart apache2"
      end

      def restart_services
        monit_command "-g daemons restart all"
      end

      def start_first_run_services
        FileUtils.cd latest_deploy do
          run_now! "#{bundle_cleanup}; export RAILS_ENV=#{dep_config.get(:env)}; bundle exec rails runner \"SystemWifi.reconfigure! if SystemWifi.supported?\""
        end
      end

    end
  end
end

