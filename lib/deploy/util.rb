module Deploy
  class Util

    def self.camelize(string)
      string = string.to_s
      indexes = [0]
      string.size.times { |i| indexes << (i + 1) if string[i,1] == '_' }
      indexes.each    { |i| string[i] = string[i,1].upcase }
      string.gsub("_", "")
    end

    def self.recipe_class(environment)
      environment_recipe = "#{VIRTUAL_APP_ROOT}/deploy/recipes/#{environment}.rb"
      recipe_name = parse_for(environment_recipe, :recipe)

      require "#{APP_ROOT}/lib/deploy/recipes/#{recipe_name}.rb"

      recipe_clazz = eval("::Deploy::Recipes::#{camelize(recipe_name)}")
      recipe_clazz.class_eval load_environment_recipe_file(environment_recipe).join('')
      recipe_clazz
    end

    def self.parse_for(file, param)
      load_environment_recipe_file(file).each do |line|
        if /#{param}\s+(.+)/ =~ line
          return eval($1)
        end
      end
    end

    def self.load_environment_recipe_file(file)
      return @environment_recipe_file if @environment_recipe_file
      @environment_recipe_file = File.readlines(file)
    end

    def self.methods_list(recipe_clazz)
      if recipe_clazz
        recipe_clazz.all_descriptions.each do |description|
          puts "#{spacing(description.first, 40)}#{description.last}"
        end
      end
      return 0
    end

    def self.recipe_list
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

    def self.config_environment
      load_config("#{VIRTUAL_APP_ROOT}/deploy/configs/#{dep_config.get(:env)}.rb")
    end

    def self.custom_config(file)
      load_config(file)
    end

    def self.load_config(file)
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

    def self.set_paths!
      dep_config.set :app_root,        "#{dep_config.get(:deploy_root)}/#{dep_config.get(:app_name)}"
      dep_config.set :deploy_tmp_path, "#{dep_config.get(:app_root)}/tmp"
      dep_config.set :current_path,    "#{dep_config.get(:app_root)}/current"
      dep_config.set :shared_path,     "#{dep_config.get(:app_root)}/shared"
      dep_config.set :releases_path,   "#{dep_config.get(:app_root)}/releases"
    end

    def self.set(key,value)
      dep_config.set(key,value)
    end

    def self.set_parameters(parameters)
      return unless parameters
      params = parameters.split(',')
      params.each do |p|
        key, value = p.split('=')
        dep_config.set(key,value)
      end
    end

    def self.required_params(options)
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

    def self.spacing(word, spaces)
      spaces_num = spaces - word.size
      spaces_num.times{ word << ' '}
      word
    end

  end
end

