module Deploy
  class Setup

    def self.init(options, summary)
      # Assign the parsed options to local variables
      list_tasks_modules   = options[:list]
      return Deploy::Util.tasks_modules_list if list_tasks_modules

      if options[:verbose] && options[:quiet]
        puts "You cannot have quiet and verbose at the same time"
        return 1
      end

      show_tasks     = options[:tasks]
      method         = options[:method]
      config_file    = options[:config]

      Deploy::Util.set_parameters(options[:parameters])

      dep_config.set :env,     options[:environment]
      dep_config.set :dry_run, options[:dry]
      dep_config.set :raw,     options[:raw]

      dep_config.set :verbose, true

      if options[:verbose] || options[:dry]
        options[:quiet] = options[:raw] = false
        dep_config.set :verbose, true
      end

      if options[:quiet] || options[:raw]
        dep_config.set :verbose, false
      end

      # Set the configuration options
      dep_config.set :deploy_root,    "/var/www"
      dep_config.set :app_name,       "test"
      dep_config.set :shell,          "/bin/bash"
      dep_config.set :app_root,       "#{dep_config.deploy_root}/#{dep_config.app_name}"
      dep_config.set :use_bundler,    false
      dep_config.set :composite_name, "#{dep_config.app_name}-#{dep_config.env}"

      # Allow methods to manually set the required params in order for it to run

      Deploy::Util.config_environment
      Deploy::Util.custom_config(config_file) if config_file

      require "#{VIRTUAL_APP_ROOT}/config/deploy_tasks.rb"
      return Deploy::Util.tasks_list(DeployRecipes) if show_tasks

      if method.to_s == ''
        puts summary unless config_present?(:dry_run)
        return 1
      end

      DeployRecipes.send(method.to_sym)

      unless DeployRecipes.commands.empty?
        DeployRecipes.push!
      end

      return 0
    end

  end
end

