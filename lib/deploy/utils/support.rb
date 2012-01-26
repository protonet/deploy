module Deploy
  module Utils
    class Support
      class << self

        def camelize(string)
          indexes = [0]
          string.size.times { |i| indexes << (i + 1) if string[i,1] == '_' }
          indexes.each    { |i| string[i] = string[i,1].upcase }
          string.gsub("_", "")
        end

        def recipe_name(v_path, recipe)
          map_default_recipes

          custom_recipe = "#{v_path}/deploy/recipes/#{recipe}.rb"

          recipe_clazz = nil
          recipe_name = ''

          if File.exists?(custom_recipe)
            require custom_recipe
            recipe_name = custom_recipe
            recipe_clazz = eval("::#{Support.camelize(recipe)}")
          else
            begin
              # Check if we are using an alias
              alias_recipe = dep_config.get_clazz(recipe)
              recipe       = alias_recipe if alias_recipe && alias_recipe != recipe

              recipe_name = "deploy/recipes/#{recipe}"
              require recipe_name
              recipe_clazz = eval("::Deploy::Recipes::#{Support.camelize(recipe)}")
            rescue Exception => e
              # The recipe that was specified does not exist in the default recipes
              puts "Error: #{e}"
            end
          end

          [recipe_name, recipe_clazz]
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
          sorted_files = []

          Dir["#{APP_ROOT}/lib/deploy/recipes/*.rb"].each do |file_name|
            chopped_file = file_name.split('/').last
            unless excluded_files.include?(chopped_file)
              sorted_files << chopped_file.split('.').first
            end
          end

          Dir["#{VIRTUAL_APP_ROOT}/deploy/recipes/*.rb"].each do |file_name|
            sorted_files << file_name.split('/').last.split('.').first
          end

          sorted_files.sort.each {|sorted_file| puts sorted_file}

          return 0
        end

        def map_default_recipes
          dep_config.set_clazz "pdm", "padrino_data_mapper"
          dep_config.set_clazz "rdm", "rails_data_mapper"
          dep_config.set_clazz "pn",  "protonet"
        end

        def config_environment
          load_config("#{VIRTUAL_APP_ROOT}/deploy/configs/#{dep_config.get(:env)}.rb")
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
          dep_config.set :app_root,        "#{dep_config.get(:deploy_root)}/#{dep_config.get(:app_name)}"
          dep_config.set :deploy_tmp_path, "#{dep_config.get(:app_root)}/tmp"
          dep_config.set :current_path,    "#{dep_config.get(:app_root)}/current"
          dep_config.set :shared_path,     "#{dep_config.get(:app_root)}/shared"
          dep_config.set :releases_path,   "#{dep_config.get(:app_root)}/releases"
        end

        def set(key,value)
          dep_config.set(key,value)
        end

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
            :default => [:environment, :method],
            :methods => [],
            :revert  => [:environment],
          }

          return r_params[:methods] if options[:methods]
          return r_params[:revert]  if options[:revert]
          return []                 if options[:list] || options[:generate]
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
end

