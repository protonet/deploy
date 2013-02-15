module Deploy
  class Setup

    def self.init(options, summary)
      process_options(options)

      Deploy::Util.config_environment
      Deploy::Util.custom_config(config_file) if options[:config]

      require "#{VIRTUAL_APP_ROOT}/config/deploy_tasks.rb"
      return Deploy::Util.tasks_list(DeployTasks) if options[:tasks]

      if options[:task].to_s == ''
        raise summary unless config_present?(:dry_run)
      end

      DeployTasks.send(options[:task].to_sym)

      unless DeployTasks.commands.empty?
        DeployTasks.push!
      end

      return 0
    rescue Exception => e
      puts "Error: #{e}" unless options[:quiet]
      return 1
    end

    def self.process_options(options)
      if options[:list]
        Deploy::Util.tasks_modules_list
        return
      end

      # Set any parameters passed in
      Deploy::Util.set_parameters(options[:parameters])

      if options[:test]
        options[:quiet] = true
        options[:dry]   = true
      else
        options[:quiet] = false  if options[:dry]
      end

      # Set the configuration options
      dep_config.set :env,            options[:environment]
      dep_config.set :dry_run,        options[:dry]
      dep_config.set :raw,            options[:raw]
      dep_config.set :verbose,        (options[:quiet] || options[:raw]) ? false : true
      dep_config.set :deploy_root,    "/var/www"
      dep_config.set :app_name,       "test"
      dep_config.set :shell,          "/bin/bash"
      dep_config.set :app_root,       "#{dep_config.deploy_root}/#{dep_config.app_name}"
      dep_config.set :use_bundler,    false
      dep_config.set :composite_name, "#{dep_config.app_name}-#{dep_config.env}"
    end

  end
end

