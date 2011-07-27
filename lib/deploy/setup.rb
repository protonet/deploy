module Deploy
  class Setup

    class << self

      def init(options, summary)
        # Check whether we have the minimum set of options
        required_params(options).each do |param|
          unless options.keys.include?(param)
            puts summary
            return 1
          end
        end

        # Assaign the parsed options to local variables
        list_recipes   = options[:list]
        return recipe_list if list_recipes

        show_methods   = options[:methods]
        recipe         = options[:recipe]
        should_revert  = options[:revert]
        method = should_revert ? "revert" : options[:method]
        config_file    = options[:config]

        set_parameters(options[:parameters])

        dep_config.set :env,     options[:environment]
        dep_config.set :dry_run, options[:dry]
        dep_config.set :verbose, (dep_config.get(:dry_run) && dep_config.get(:env) != 'test') ? true : !options[:quiet]

        # Set the configuration options
        dep_config.set :deploy_root, "/var/www"
        dep_config.set :app_name,    "test"
        dep_config.set :shell,       "/bin/bash"

        config_environment
        custom_config(config_file) if config_file

        # Map short names for the recipes
        map_default_recipes

        # Load the recipe
        # TODO: Add a custom clazz option so that people can specify the class from the custom recipe
        recipe_clazz = nil
        custom_recipe = "#{VIRTUAL_APP_ROOT}/deploy/recipes/#{recipe}.rb"

        if File.exists?(custom_recipe)
          require custom_recipe
          recipe_clazz = eval("::#{::Deploy::Util.camelize(recipe)}")
        else
          begin
            # Check if we are using an alias
            # puts "THE RECIPE IS #{recipe}"
            alias_recipe = dep_config.get_clazz(recipe)
            recipe = alias_recipe if alias_recipe && alias_recipe != recipe

            require "deploy/recipes/#{recipe}"
            recipe_clazz = eval("::Deploy::Recipes::#{::Deploy::Util.camelize(recipe)}")
          rescue Exception => e
            puts "Error: #{e}"
            # The recipe that was specified does not exist in the default recipes
          end
        end

        return methods_list(recipe_clazz) if show_methods

        recipe_clazz.new.send(method.to_sym) if recipe_clazz
        return 0
      end

      def methods_list(recipe_clazz)
        if recipe_clazz
          recipe_clazz.all_descriptions.each do |description|
            puts "#{spacing(description.first, 40)}#{description.last}"
          end
        end
        return 0
      end

      def recipe_list
        excluded_files = ['base.rb', 'common.rb']

        Dir["#{APP_ROOT}/lib/deploy/recipes/*.rb"].each do |file_name|
          puts file_name.split('.').first unless excluded_files.include?(file_name)
        end

        Dir["#{VIRTUAL_APP_ROOT}/deploy/recipes/*.rb"].each do |file_name|
          puts file_name.split('.').first
        end

        return 0
      end

      def map_default_recipes
        dep_config.set_clazz "pdm", "padrino_data_mapper"
        dep_config.set_clazz "rdm", "rails_data_mapper"
        dep_config.set_clazz "pn",  "protonet"
      end

      def config_environment
        load_config("#{VIRTUAL_APP_ROOT}/deploy/environments/#{dep_config.get(:env)}.rb")
      end

      def custom_config(file)
        load_config(file)
      end

      def load_config(file)
        if File.exists?(file)
          file_contents = ""
          File.open(file, "r") do |infile|
            while (line = infile.gets)
              file_contents += line
            end
          end
          eval file_contents
        end
        set_paths!
      end

      def set_paths!
        dep_config.set :app_root,      "#{dep_config.get(:deploy_root)}/#{dep_config.get(:app_name)}"
        dep_config.set :current_path,  "#{dep_config.get(:app_root)}/current"
        dep_config.set :shared_path,   "#{dep_config.get(:app_root)}/shared"
        dep_config.set :releases_path, "#{dep_config.get(:app_root)}/releases"
      end

      def set(key,value)
        dep_config.set(key,value)
      end

      private

        def set_parameters(parameters)
          return unless parameters
          params = parameters.split(',')
          params.each do |p|
            key, value = p.split('=')
            dep_config.set(key,value)
          end
        end

        def required_params(options)
          r_params = {
            :default => [:recipe, :environment, :method],
            :methods => [:recipe],
            :revert  => [:recipe, :environment],
          }

          return r_params[:methods] if options[:methods]
          return r_params[:revert] if options[:revert]
          r_params[:default]
        end

        def spacing(word, spaces)
          spaces_num = spaces - word.size
          spaces_num.times{ word << ' '}
          word
        end

    end
  end
end

