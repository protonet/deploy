module Deploy
  module CommonMethods

    def self.included(base)
      base.class_eval do

        desc :setup, "create the directory structure needed for a deployment" do
          queue [:create_directories]
          process_queue
        end

        desc :deploy, "Deploy the app to the server" do
          queue [
            :pull_code,
            :restart
          ]
          process_queue
        end

        desc :create_directories, "create the directory structure" do
          mkdir "#{dep_config.app_root}/tmp"
          mkdir "#{dep_config.app_root}/log"
        end

        desc :pull_code, "Pulls the code from the git repo" do
          remote "cd #{dep_config.app_root}"

          if dep_config.exists?(:git_branch)
            on_bad_exit "git checkout #{dep_config.git_branch}", [
              "git checkout -t -b #{dep_config.git_branch} #{dep_config.git_branch_origin}/#{dep_config.git_branch}"
            ]
          end

          remote "git checkout ."
          remote "git pull"
        end

        desc :bundle, "Runs bundle to make sure all the required gems are on the ststem" do
          remote "cd #{dep_config.app_root}"
          remote "bundle install --without test development --deployment"
        end

        desc :restart, "Causes the server to restart for this app" do
          remote "touch #{dep_config.app_root}/tmp/restart.txt"
        end

      end
    end

  end
end

