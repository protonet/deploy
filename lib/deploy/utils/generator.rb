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

          file_path = "#{VIRTUAL_APP_ROOT}/deploy/configs"

          unless File.exist?(file_path)
            puts "Creating #{file_path}"
            FileUtils.mkdir_p file_path
          end

          unless File.exist?(file_name = "#{file_path}/#{@@params[:name]}.rb")
            puts "Generating #{file_name}..."
            File.open(file_name, 'w') do |f|
              @@params.each do |k,v|
                puts "Setting #{k} to #{v}"
                f.write("set :#{k}, \"#{v}\"\n") unless [:type,:name].include?(k)
              end
              puts "Done!"
            end

            return 0
          else
            puts "#{file_path}/#{@@params[:name]}.rb already exists. Will not overwrite!"
            return 1
          end
        end

        def recipe

        end
      end




    end
  end
end

