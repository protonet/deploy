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
      should_revert  = options[:revert]
      method         = should_revert ? "revert" : options[:method]
      config_file    = options[:config]

      Deploy::Util.set_parameters(options[:parameters])

      dep_config.set :env,     options[:environment]
      dep_config.set :dry_run, options[:dry]
      dep_config.set :verbose, (dep_config.get(:dry_run) && dep_config.get(:env) != 'test') ? true : !options[:quiet]

      # Set the configuration options
      dep_config.set :deploy_root, "/var/www"
      dep_config.set :app_name,    "test"
      dep_config.set :shell,       "/bin/bash"

      Deploy::Util.config_environment
      Deploy::Util.custom_config(config_file) if config_file

      # Load the recipe
      recipe_clazz = Deploy::Util.recipe_class(dep_config.get(:env))

      return Deploy::Util.methods_list(recipe_clazz) if show_methods

      recipe_clazz.new.send(method.to_sym) if recipe_clazz
      return 0
    end

  end
end

