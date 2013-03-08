module Deploy
  class Setup

    def self.init(options, summary)
      process_options(options)

      Deploy::Util.config_environment
      Deploy::Util.custom_config(config_file) if options[:config]

      # Require your tasks class
      require "#{VIRTUAL_APP_ROOT}/config/deploy_tasks.rb"
      return Deploy::Util.tasks_list(DeployTasks) if options[:all_tasks]

      # tasks is the only required option, so make sure it is there
      if (options[:tasks] = options[:tasks].to_s) == ''
        raise summary
      end

      puts "PARAMS #{options[:parameters]}"

      tasks = options[:tasks].split(',')
      tasks = with_tasks(tasks, options[:with])
      tasks = without_tasks(tasks, options[:without])

      # Execute the task
      tasks.each do |task|
        DeployTasks.send(task.to_sym)
      end

      # If there are any commands still in the commands cache, push them
      DeployTasks.push! unless DeployTasks.commands.empty?

      return 0
    rescue Exception => e
      puts "Error: #{e}" unless options[:quiet]
      # puts summary
      return 1
    end

    def self.process_options(options)
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
      dep_config.set :bundler_use,    false
      dep_config.set :composite_name, "#{dep_config.app_name}-#{dep_config.env}"

      # Mail settings
      dep_config.set :mail_use,  false
      dep_config.set :mail_via,  :sendmail # Or :smtp
      dep_config.set :mail_to,   "test@example.com"
      dep_config.set :mail_from, "test@example.com"

      # Sendmail options
      # dep_config.set :mail_via_options => {
      #   :location  => '/path/to/sendmail', # defaults to 'which sendmail' or '/usr/sbin/sendmail' if 'which' fails
      #   :arguments => '-t' # -t and -i are the defaults
      # }

      # SMTP options
      # dep_config.set :mail_via_options => {
      #   :address        => 'smtp.yourserver.com',
      #   :port           => '25',
      #   :user_name      => 'user',
      #   :password       => 'password',
      #   :authentication => :plain, # :plain, :login, :cram_md5, no auth by default
      #   :domain         => "localhost.localdomain" # the HELO domain provided by the client to the server
      # }

      # SMTP Gmail options
      # dep_config.set :mail_via_options => {
      #   :address              => 'smtp.gmail.com',
      #   :port                 => '587',
      #   :enable_starttls_auto => true,
      #   :user_name            => 'user',
      #   :password             => 'password',
      #   :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
      #   :domain               => "localhost.localdomain" # the HELO domain provided by the client to the server
      # }
    end

    def self.with_tasks(tasks, withs)
      withs ||= ""
      withs = withs.to_s.split(',')
      tasks + withs
    end

    def self.without_tasks(tasks, withouts)

      tasks
    end

  end
end

