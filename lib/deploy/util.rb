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

        DeployConfig.common
        DeployConfig.send(dep_config.env) if config_present?(:env)

        dep_config.set :app_root,       "#{dep_config.deploy_root}/#{dep_config.app_name}"
        dep_config.set :composite_name, "#{dep_config.app_name}-#{dep_config.env}"
      end
    end

    def self.tasks_list(recipe_clazz)
      if recipe_clazz
        recipe_clazz.all_descriptions.each do |description|
          puts "#{recipe_clazz}:  #{spacing(description.first, 40)}#{description.last}"
        end
      end
      return 0
    end

    def self.tasks_modules_list
      sorted_files = []

      Dir["#{APP_ROOT}/lib/deploy/tasks/*.rb"].each do |file_name|
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

    def self.spacing(word, spaces)
      word       = word.to_s
      spaces_num = spaces - word.size

      spaces_num.times{ word << ' '}

      word
    end

  end
end

