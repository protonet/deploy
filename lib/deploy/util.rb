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

    def self.set_parameters(parameters)
      return unless parameters
      params = parameters.split(',')
      params.each do |p|
        key, value = p.split('=')
        puts "Setting #{key} = #{value}"
        dep_config.set(key,value)
        puts "GETTING #{key} = #{dep_config.get(key)}"
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

