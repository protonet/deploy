module Deploy
  module Recipes
    module GitMethods

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

          desc :clone_code, "Clone the repo" do
            remote "cd #{dep_config.deploy_root}"

            if dep_config.exists?(:git_branch)
              remote "git clone -b #{dep_config.env} #{dep_config.git_repo} #{dep_config.app_name}"
            else
              remote "git clone #{dep_config.git_repo} #{dep_config.app_name}"
            end
          end

          desc :merge_branch, "Merge one branch into another" do
            from_branch, to_branch = require_params(:git_from_branch, :git_to_branch)

            starting_branch = `git rev-parse --abbrev-ref HEAD`.strip

            cmd = []
            cmd << "git checkout #{to_branch}" if starting_branch != to_branch
            cmd << "git merge #{from_branch}"
            cmd << "git push"

            local cmd.join(' && ')

            local "git checkout #{starting_branch}"
          end

          desc :tag_and_release, 'Makes a tag from the current staging branch' do
            from_branch = require_params(:git_from_branch)

            starting_branch = `git rev-parse --abbrev-ref HEAD`.strip

            cmd = []
            cmd << "git checkout #{from_branch}" if starting_branch != from_branch
            cmd << "git tag release-#{Time.now.utc.strftime('%Y%m%d%H%M%S')}"
            cmd << "git push"
            cmd << "git push --tags"

            local cmd.join(' && ')

            local "git checkout #{starting_branch}"
          end

        end
      end

    end
  end
end
