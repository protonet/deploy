module Deploy
  class Setup

    def self.init(options, summary)
      # Check whether we have the minimum set of options
      ::Deploy::Util.required_params(options).each do |param|
        unless options.keys.include?(param)
          puts summary if should_i_do_it?
          return 1
        end
      end

      # Assign the parsed options to local variables
      list_recipes   = options[:list]
      return Deploy::Util.recipe_list if list_recipes

      show_methods   = options[:methods]
      method         = options[:method]
      config_file    = options[:config]

      Deploy::Util.set_parameters(options[:parameters])

      dep_config.set :env,     options[:environment]
      dep_config.set :dry_run, options[:dry]
      dep_config.set :verbose, (dep_config.dry_run && dep_config.env != 'test') ? true : !options[:quiet]

      # Set the configuration options
      dep_config.set :deploy_root, "/var/www"
      dep_config.set :app_name,    "test"
      dep_config.set :shell,       "/bin/bash"
      dep_config.set :app_root,    "#{dep_config.deploy_root}/#{dep_config.app_name}"

      Deploy::Util.config_environment
      Deploy::Util.custom_config(config_file) if config_file

      require "#{VIRTUAL_APP_ROOT}/config/deploy_recipes.rb"
      return Deploy::Util.methods_list(DeployRecipes) if show_methods

      DeployRecipes.send(method.to_sym)
      return 0
    end

  end
end

