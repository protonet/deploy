module Deploy
  module CommonMethods

    def self.included(base)
      base.class_eval do

        desc "setup", "create the directory structure needed for a deployment", true do
          queue [:create_directories]
          process_queue
        end

        desc "push_create", "Deploy the app to the server, and completely wipe the database tables and recreate them", true do
          queue [
            :set_prev_release_tag,
            :set_release_tag,
            :get_and_pack_code,
            :push_code,
            :create_release_dir,
            :link,
            :unpack,
            :clean_up,
            :restart
          ]
          process_queue
        end

        desc "pull_create", "Deploy the app to the server, and completely wipe the database tables and recreate them", true do
          queue [
            :set_prev_release_tag,
            :set_release_tag,
            :create_release_dir,
            :link,
            :pull_code,
            :clean_up,
            :restart
          ]
          process_queue
        end

        desc "push_update", "Deploy the app to the server", true do
          queue [
            :set_prev_release_tag,
            :get_and_pack_code,
            :push_code,
            :set_release_tag,
            :create_release_dir,
            :link,
            :unpack,
            :clean_up,
            :restart
          ]
          process_queue
        end

        desc "pull_update", "Deploy the app to the server", true do
          queue [
            :set_prev_release_tag,
            :set_release_tag,
            :create_release_dir,
            :link,
            :pull_code,
            :clean_up,
            :restart
          ]
          process_queue
        end

        desc "create_directories", "create the directory structure" do
          mkdir "#{dep_config.get(:app_root)}/tmp"
          mkdir "#{dep_config.get(:shared_path)}/log"
          mkdir "#{dep_config.get(:shared_path)}/dep_config"
          mkdir "#{dep_config.get(:shared_path)}/vendor"
          mkdir "#{dep_config.get(:shared_path)}/tmp"
          mkdir "#{dep_config.get(:releases_path)}"
        end

        desc "get_and_pack_code", "Makes sure the code is up to date and then tars it up" do
          run_now! "cd #{dep_config.get(:local_root)}"
          run_now! "git pull origin master"
          run_now! "tar --exclude='.git' --exclude='log' --exclude='tmp' --exclude='vendor/ruby' -cjf /tmp/#{dep_config.get(:app_name)}.tar.bz2 *"
        end

        desc "push_code", "Pushes the code to the server" do
          cmd = "rsync "
          cmd << dep_config.get(:extra_rsync_options) unless !dep_config.get(:extra_rsync_options)
          cmd << "/tmp/#{dep_config.get(:app_name)}.tar.bz2 #{dep_config.get(:username)}@#{dep_config.get(:remote)}:/tmp/"
          run_now! cmd
        end

        desc "pull_code", "Pulls the code from the git repo" do
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
          remote "unzip -o #{local_repo}.zip -x log/* tmp/* vender/ruby/*"
        end

        desc "set_release_tag", "Sets the release tag number" do
          dep_config.set "release_tag", Time.now.strftime('%Y%m%d%H%M%S')
        end

        desc "unpack", "Unpacks the code to the correct directories" do
          file_exists "/tmp/#{dep_config.get(:app_name)}.tar.bz2",
            [
              "cd #{dep_config.get(:releases_path)}/#{dep_config.get("release_tag")}",
              "tar -xjf /tmp/#{dep_config.get(:app_name)}.tar.bz2",
            ]
          remote "find #{dep_config.get(:current_path)} -type d -exec chmod 775 '{}' \\;"
          remote "find #{dep_config.get(:current_path)} -type f -exec chmod 664 '{}' \\;"
          remote "chown -Rf #{dep_config.get(:remote_user)}:#{dep_config.get(:remote_group)} #{dep_config.get(:app_root)}"
        end

        desc "create_release_dir", "creates the release directory" do
          remote "mkdir #{dep_config.get(:releases_path)}/#{dep_config.get("release_tag")}"
        end

        desc "link", "Create the links for which the code can be placed" do
          link_exists(dep_config.get(:current_path), [ "rm #{dep_config.get(:current_path)}" ])
          remote "ln -s #{dep_config.get(:releases_path)}/#{dep_config.get("release_tag")} #{dep_config.get(:current_path)}"
          remote "ln -s #{dep_config.get(:shared_path)}/log #{dep_config.get(:current_path)}/log"
          remote "ln -s #{dep_config.get(:shared_path)}/vendor #{dep_config.get(:current_path)}/vendor"
          remote "ln -s #{dep_config.get(:shared_path)}/tmp #{dep_config.get(:current_path)}/tmp"
        end

        desc "bundle", "Runs bundle to make sure all the required gems are on the ststem", true do
          remote "rvm rvmrc trust #{dep_config.get(:current_path)}"
          remote "cd #{dep_config.get(:current_path)}"
          remote "bundle install --without test development --deployment"
          remote "find #{dep_config.get(:shared_path)}/vendor -type d -name \"bin\" -exec chmod -Rf 775 '{}' \\;"
        end

        desc "clean_up", "Deletes any old releases if there are more than the max configured releases" do
          remote "cd #{dep_config.get(:releases_path)}"
          remote "export NUM_RELEASES=`ls -trl -m1 | wc -l`"
          remote "export NUM_TO_REMOVE=$(( $NUM_RELEASES - #{dep_config.get(:max_num_releases)} ))"
          remote "export COUNTER=1"
          on_good_exit "[[ $NUM_TO_REMOVE =~ ^[0-9]+$ ]] && [[ $COUNTER =~ ^[0-9]+$ ]] && [[ $NUM_TO_REMOVE -ge 1 ]]",
            [
              "for i in $( ls -tlr -m1 ); do echo \"removing $i\"; rm -rf $i; [[ $COUNTER == $NUM_TO_REMOVE ]] && break; COUNTER=$(( $COUNTER + 1 )); done",
            ]
        end

        desc "restart", "Causes the server to restart for this app", true do
          remote "touch #{dep_config.get(:current_path)}/tmp/restart.txt"
        end

        desc "clear_tmp", "clears the tmp dir in the deploy root"
        def clear_tmp
          file_exists dep_config.get(:deploy_tmp_path), [ "rm -rf #{dep_config.get(:deploy_tmp_path)}/*" ]
          push!
        end

        desc "revert", "Reverts a one of the previous deployments" do
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

        desc "set_prev_release_tag", "Sets the name of the previous version of the app deployed" do
          cmd = "cd #{dep_config.get(:releases_path)} && ls -tl -m1"
          return_value = run_now_with_return! ssh_cmd(cmd)
          if should_i_do_it?
            prev_release_tag = return_value.split.reject{|v|v !~ /^\d+$/}.first
            if prev_release_tag
              prev_release_tag = prev_release_tag.strip
              dep_config.set(:prev_release_tag, prev_release_tag)
              puts "Prev release tag #{prev_release_tag}"
            else
              puts "No previous release tag"
            end
          end
        end

        desc "on_remote_failure", "What will happen if the remote deployment fails" do
          puts "\n*** remote_failure ***"
          remote "cd #{dep_config.get(:app_root)}"
          if dep_config.get(:prev_release_tag)
            puts "Rolling back to previous release #{dep_config.get(:release_tag)}"
            on_good_exit "ls -l | grep #{dep_config.get(:release_tag)} 2>&1 > /dev/null",[
              "rm #{dep_config.get(:current_path)}",
              "ln -s #{dep_config.get(:releases_path)}/#{dep_config.get(:prev_release_tag)} #{dep_config.get(:current_path)}",
            ]
            bundle
            push!
            exit(1)
          end
        end

        desc "on_local_failure", "What will happen if the local deployment fails" do
          # Nothing to do here yet
          exit(1)
        end

      end
    end

  end
end

