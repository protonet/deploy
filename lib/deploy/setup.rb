module Deploy
  class Setup

    class << self

      def init(options, summary)
        # Check whether we have the minimum set of options
        ::Deploy::Utils::Support.required_params(options).each do |param|
          unless options.keys.include?(param)
            puts summary if should_i_do_it?
            return 1
          end
        end

        # Assaign the parsed options to local variables
        list_recipes   = options[:list]
        return recipe_list if list_recipes

        generate    = options[:generate]
        return ::Deploy::Utils::Generator.generate(generate)

        show_methods   = options[:methods]
        recipe         = options[:recipe]
        should_revert  = options[:revert]
        method = should_revert ? "revert" : options[:method]
        config_file    = options[:config]

        ::Deploy::Utils::Support.set_parameters(options[:parameters])

        dep_config.set :env,     options[:environment]
        dep_config.set :dry_run, options[:dry]
        dep_config.set :verbose, (dep_config.get(:dry_run) && dep_config.get(:env) != 'test') ? true : !options[:quiet]

        # Set the configuration options
        dep_config.set :deploy_root, "/var/www"
        dep_config.set :app_name,    "test"
        dep_config.set :shell,       "/bin/bash"

        ::Deploy::Utils::Support.config_environment
        ::Deploy::Utils::Support.custom_config(config_file) if config_file

        # Load the recipe
        # TODO: Add a custom clazz option so that people can specify the class from the custom recipe
        recipe_name, recipe_clazz = ::Deploy::Utils::Support.recipe_name(VIRTUAL_APP_ROOT, recipe)

        return ::Deploy::Utils::Support.methods_list(recipe_clazz) if show_methods

        recipe_clazz.new.send(method.to_sym) if recipe_clazz
        return 0
      end

    end
  end
end

