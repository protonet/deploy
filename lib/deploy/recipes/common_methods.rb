module Deploy
  module Recipes
    module CommonMethods

      def self.included(base)
        base.class_eval do

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

        end
      end

    end
  end
end

