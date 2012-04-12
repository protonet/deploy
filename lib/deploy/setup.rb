module Deploy
  class Setup

    def self.init(options, summary)
      # options = ::Deploy::Utils::Support.clean_options(options)
      # Check whether we have the minimum set of options
      ::Deploy::Utils::Support.required_params(options).each do |param|
        unless options.keys.include?(param)
          puts summary if should_i_do_it?
          return 1
        end
      end

      # Assign the parsed options to local variables
      list_recipes   = options[:list]
      return recipe_list if list_recipes

      support   = ::Deploy::Utils::Support
      generator = ::Deploy::Utils::Generator

      generate    = options[:generate]
      return generator.generate(generate) if generate

      show_methods   = options[:methods]
      recipe         = options[:recipe] || options[:environment]
      should_revert  = options[:revert]
      method         = should_revert ? "revert" : options[:method]
      config_file    = options[:config]

      support.set_parameters(options[:parameters])

      dep_config.set :env,     options[:environment]
      dep_config.set :dry_run, options[:dry]
      dep_config.set :verbose, (dep_config.get(:dry_run) && dep_config.get(:env) != 'test') ? true : !options[:quiet]

      # Set the configuration options
      dep_config.set :deploy_root, "/var/www"
      dep_config.set :app_name,    "test"
      dep_config.set :shell,       "/bin/bash"

      support.config_environment
      support.custom_config(config_file) if config_file

      # Load the recipe
      recipe_name, recipe_clazz = support.recipe_name(dep_config.get(:env))

      return support.methods_list(recipe_clazz) if show_methods

      recipe_clazz.new.send(method.to_sym) if recipe_clazz
      return 0
    end

  end
end

