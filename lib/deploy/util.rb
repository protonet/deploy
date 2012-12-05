module Deploy
  class Util

    def self.config_environment
      load_config("#{VIRTUAL_APP_ROOT}/config/deploy_config.rb")
    end

    def self.custom_config(file)
      load_config(file)
    end

    def self.load_config(file)
      if File.exists?(file)
        require file
        DeployConfig.send(dep_config.env)
        dep_config.set :app_root, "#{dep_config.deploy_root}/#{dep_config.app_name}"
      end
    end

    def self.camelize(string)
      string = string.to_s
      indexes = [0]
      string.size.times { |i| indexes << (i + 1) if string[i,1] == '_' }
      indexes.each    { |i| string[i] = string[i,1].upcase }
      string.gsub("_", "")
    end

    def self.methods_list(recipe_clazz)
      if recipe_clazz
        recipe_clazz.all_descriptions.each do |description|
          puts "#{recipe_clazz}:  #{spacing(description.first, 40)}#{description.last}"
        end
      end
      return 0
    end

    def self.recipe_list
      sorted_files = []

      Dir["#{APP_ROOT}/lib/deploy/recipes/*.rb"].each do |file_name|
        chopped_file = file_name.split('/').last
        sorted_files << chopped_file.split('.').first
      end

      sorted_files.each {|sorted_file| puts sorted_file}

      return 0
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
      word       = word.to_s
      spaces_num = spaces - word.size

      spaces_num.times{ word << ' '}

      word
    end

  end
end

