module Deploy
  module Recipes
    module RubyMethods

      def self.included(base)
        base.class_eval do

          task :rake, 'Run a command via rake' do
            cmd = []
            cmd << "cd #{dep_config.app_root}"
            cmd << "bundle exec" if present?(:use_bundler)
            cmd << "rake #{command}"
            remote cmd.join(' ')
          end

        end
      end

    end
  end
end

