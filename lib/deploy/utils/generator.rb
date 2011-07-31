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
          require 'fileutils'
          require 'erb'

          file = create_file("#{VIRTUAL_APP_ROOT}/deploy/recipes", "#{@@params[:name]}.rb")
          return 1 if file.nil?

          additional_require = ''
          clazz_name         = ''
          extends_file       = ''
          prepends      = []
          appends       = []
          method_names  = []

          result = ERB.new(recipe_template_contents).result(binding)

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

