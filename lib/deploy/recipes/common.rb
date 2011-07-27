module Deploy
  module Recipes
    module Common

      def self.included(base)
        base.class_eval do
          desc "setup", "create the directory structure needed for a deployment"
          def setup
            self.class.actions = [:create_directories]
            self.class.run_actions(self)
          end

          desc "deploy_create", "Deploy the app to the server, and completely wipe the database tables and recreate them"
          def deploy_create
            self.class.actions = [
              :get_and_pack_code,
              :push_code,
              :get_release_tag,
              :link,
              :unpack,
              :bundle,
              :setup_db,
              :auto_migrate,
              :clean_up,
              :restart
            ]
            self.class.run_actions(self)
          end

          desc "deploy", "Deploy the app to the server"
          def deploy_push
            self.class.actions = [
              :get_and_pack_code,
              :push_code,
              :get_release_tag,
              :link,
              :unpack,
              :bundle,
              :auto_upgrade,
              :clean_up,
              :restart
            ]
            self.class.run_actions(self)
          end

          desc "deploy", "Deploy the app to the server"
          def deploy_pull
            self.class.actions = [
              :get_release_tag,
              :link,
              :pull_code,
              :bundle,
              :auto_upgrade,
              :clean_up,
              :restart
            ]
            self.class.run_actions(self)
          end

          desc "create_directories", "create the directory structure"
          def create_directories
            mkdir "#{dep_config.get(:app_root)}/tmp"
            mkdir "#{dep_config.get(:shared_path)}/log"
            mkdir "#{dep_config.get(:shared_path)}/dep_config"
            mkdir "#{dep_config.get(:shared_path)}/vendor"
            mkdir "#{dep_config.get(:shared_path)}/tmp"
            mkdir "#{dep_config.get(:releases_path)}"
            remote "echo \"rvm --create use #{dep_config.get(:ruby_version) || 'default'}@#{dep_config.get(:app_name)}\" > #{dep_config.get(:app_root)}/.rvmrc"
          end

          desc "get_and_pack_code", "Makes sure the code is up to date and then tars it up"
          def get_and_pack_code
            run_now! "cd #{dep_config.get(:local_root)}"
            run_now! "git pull origin master"
            run_now! "tar --exclude='.git' --exclude='log' --exclude='tmp' --exclude='vendor/ruby' -cjf /tmp/#{dep_config.get(:app_name)}.tar.bz2 *"
          end

          desc "push_code", "Pushes the code to the server"
          def push_code
            cmd = "rsync "
            cmd << dep_config.get(:extra_rsync_options) unless !dep_config.get(:extra_rsync_options)
            cmd << "/tmp/#{dep_config.get(:app_name)}.tar.bz2 #{dep_config.get(:username)}@#{dep_config.get(:remote)}:/tmp/"
            run_now! cmd
          end

          desc "pull_code", "Pulls the code from the git repo"
          def pull_code
            tmp_path     = dep_config.get(:deploy_tmp_path)
            app_name     = dep_config.get(:app_name)
            local_repo   = "#{dep_config.get(:deploy_tmp_path)}/#{app_name}"
            server_repo  = dep_config.get(:git_repo)
            release_slot = "#{dep_config.get(:releases_path)}/#{dep_config.get(:release_tag)}"

            file_not_exists "#{tmp_path}", [ "mkdir -p #{tmp_path}" ]
            remote "cd #{tmp_path}"
            file_not_exists "#{local_repo}", [ "git clone #{server_repo} #{app_name}" ]
            remote "cd #{local_repo}"
            remote "git pull"
            file_exists "#{local_repo}.zip", [ "rm #{local_repo}.zip" ]
            remote "git archive -o #{local_repo}.zip HEAD"
            remote "cd #{release_slot}"
            remote "unzip -o #{local_repo}.zip -x log/* tmp/* vender/ruby/* .rvmrc"
          end

          def get_release_tag
            dep_config.set "release_tag", Time.now.strftime('%Y%m%d%H%M%S')
          end

          desc "unpack", "Unpacks the code to the correct directories"
          def unpack
            file_exists "/tmp/#{dep_config.get(:app_name)}.tar.bz2",
              [
                "cd #{dep_config.get(:releases_path)}/#{dep_config.get("release_tag")}",
                "tar -xjf /tmp/#{dep_config.get(:app_name)}.tar.bz2",
              ]
            remote "find #{dep_config.get(:current_path)} -type d -exec chmod 775 '{}' \\;"
            remote "find #{dep_config.get(:current_path)} -type f -exec chmod 664 '{}' \\;"
            remote "chown -Rf #{dep_config.get(:remote_user)}:#{dep_config.get(:remote_group)} #{dep_config.get(:app_root)}"
          end

          desc "link", "Create the links for which the code can be placed"
          def link
            link_exists(dep_config.get(:current_path), [ "rm #{dep_config.get(:current_path)}" ])
            remote "mkdir #{dep_config.get(:releases_path)}/#{dep_config.get("release_tag")}"
            remote "ln -s #{dep_config.get(:releases_path)}/#{dep_config.get("release_tag")} #{dep_config.get(:current_path)}"
            remote "ln -s #{dep_config.get(:shared_path)}/log #{dep_config.get(:current_path)}/log"
            remote "ln -s #{dep_config.get(:shared_path)}/vendor #{dep_config.get(:current_path)}/vendor"
            remote "ln -s #{dep_config.get(:shared_path)}/tmp #{dep_config.get(:current_path)}/tmp"
          end

          desc "bundle", "Runs bundle to make sure all the required gems are on the ststem"
          def bundle
            remote "rvm rvmrc trust #{dep_config.get(:app_root)}"
            remote "cd #{dep_config.get(:current_path)}"
            remote "bundle install --without test development --deployment"
            remote "find #{dep_config.get(:shared_path)}/vendor -type d -name \"bin\" -exec chmod -Rf 775 '{}' \\;"
          end

          desc "clean_up", "Deletes any old releases if there are more than the max configured releases"
          def clean_up
            remote "cd #{dep_config.get(:releases_path)}"
            remote "export NUM_RELEASES=`ls -trl -m1 | wc -l`"
            remote "export NUM_TO_REMOVE=$(( $NUM_RELEASES - #{dep_config.get(:max_num_releases)} ))"
            remote "export COUNTER=1"
            on_good_exit "[[ $NUM_TO_REMOVE =~ ^[0-9]+$ ]] && [[ $COUNTER =~ ^[0-9]+$ ]] && [[ $NUM_TO_REMOVE -ge 1 ]]",
              [
                "for i in $( ls -tlr -m1 ); do echo \"removing $i\"; rm -rf $i; [[ $COUNTER == $NUM_TO_REMOVE ]] && break; COUNTER=$(( $COUNTER + 1 )); done",
              ]
          end

          desc "restart", "Causes the server to restart for this app"
          def restart
            remote "touch #{dep_config.get(:current_path)}/tmp/restart.txt"
          end

          self.desc "revert", "Reverts a one of the previous deployments"
          def revert
            remote "cd #{dep_config.get(:releases_path)}"
            remote <<EOC
              counter=1
              FILES=#{dep_config.get(:releases_path)}/*
              echo "Revert to which deployment?"
              for f in $FILES; do releases[$counter]=$f; echo "${counter}. $f"; counter=$(( counter + 1 )); done
              read answer
              echo "About to revert to ${releases[$answer]}"
              rm #{dep_config.get(:current_path)}
              ln -s ${releases[$answer]} #{dep_config.get(:current_path)}
              touch #{dep_config.get(:current_path)}/tmp/restart.txt
EOC
            push!
          end
        end
      end

    end
  end
end

