module Deploy
  module Utils
    class Generator

      @@params = {}

      class << self
        def generate(params)
          params.split(',').each do |p|
            key,value = p.split('=')
            @@params[key.to_sym] = value
          end

          unless ['recipe', 'config'].include?(@@params[:type])
            puts "You have not specified a type of recipe or config"
            return 1
          end

          send @@params[:type]
        end

        def config
          unless @@params[:name]
            puts "You have not specified a name of for the config"
            return 1
          end

          require 'fileutils'

          file = create_file("#{VIRTUAL_APP_ROOT}/deploy/configs", "#{@@params[:name]}.rb")
          return 1 if file.nil?

          @@params.each do |k,v|
            puts "Setting #{k} to #{v}"
            file.write("set :#{k}, \"#{v}\"\n") unless [:type,:name].include?(k)
          end
          puts "Done!"

          return 0
        ensure
          file.close if file
        end

        def recipe
          unless @@params[:name]
            puts "You have not specified a name of for the recipe"
            return 1
          end

          require 'fileutils'
          require 'erb'

          file = create_file("#{VIRTUAL_APP_ROOT}/deploy/recipes", "#{@@params[:name]}.rb")
          return 1 if file.nil?

          if @@params[:extends]
            recipe_name, recipe_clazz = Support.recipe_name(VIRTUAL_APP_ROOT, @@params[:extends])
            extends_file = recipe_clazz
          else
            extends_file = '::Deploy::Utils::Base'
            commons_include = true
          end

          additional_require = recipe_name
          clazz_name         = Support.camelize(@@params[:name])

          prepends      = @@params[:prepends] ? @@params[:prepends].split(' ') : []
          appends       = @@params[:appends]  ? @@params[:appends].split(' ')  : []
          method_names  = @@params[:methods]  ? @@params[:methods].split(' ')  : []

          result = ERB.new(recipe_template_contents, nil, '<>').result(binding)

          file.write(result)
          return 0
        ensure
          file.close if file
        end

        def recipe_template_contents
          return @contents if @contents
          @contents = ""
          File.open("#{APP_ROOT}/lib/deploy/templates/recipe.erb",'r'){|f| @contents = f.read}
          @contents
        end

        def create_file(path, filename)

          unless File.exist?(path)
            puts "Creating #{path}"
            FileUtils.mkdir_p path
          end

          unless File.exist?(file_name = "#{path}/#{filename}")
            puts "Generating #{file_name}..."
            return File.new(file_name, "w")
          else
            puts "#{file_name} already exists. Will not overwrite!"
          end

          return nil
        end
      end
    end
  end
end

