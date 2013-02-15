module Deploy
  module Tasks
    module Ruby

      def self.included(base)
        base.class_eval do

          task :rake, 'Run a command via rake' do
            cmd = []
            cmd << "cd #{dep_config.app_root}"

            if config_present?(:bundler_use)
              cmd << "bundle exec rake #{command}"
            else
              cmd << "rake #{command}"
            end

            remote cmd.join(' && ')
          end

        end
      end

    end
  end
end

