module Deploy
  module Base
    attr_accessor :commands

    def commands
      @commands ||= []
    end

    def remote(command)
      self.commands << [:remote, command]
    end

    def local(command)
      self.commands << [:local, command]
    end

    def ssh_cmd(commands)
      cmd = "ssh "
      cmd << "#{dep_config.get(:extra_ssh_options)} " if dep_config.get(:extra_ssh_options)
      cmd << "#{dep_config.get(:username)}@#{dep_config.get(:remote)} "
      cmd << "'"
      cmd << "#{dep_config.get(:after_login)}; " if dep_config.get(:after_login)
      cmd << "#{commands}"
      cmd << "'"
    end

    def run_now!(command)
      puts "EXECUTING: #{command}" if dep_config.get(:verbose)
      system command unless dep_config.get(:dry_run)
    end

    def push!(push_now = false)
      unless self.commands.empty?
        local_commands = []
        remote_commands = []

        #TODO: Need tests to make sure local and remote work the way they are supposed to
        self.commands.each do |command|
          if command.first == :local
            puts "LOCAL: #{command.last}" if dep_config.get(:verbose)
            local_commands << command.last
          elsif command.first == :remote
            puts "REMOTE: #{command.last}" if dep_config.get(:verbose)
            remote_commands << command.last
          end
        end

        unless local_commands.empty?
          run_now! local_commands.join("; ")
        end

        unless remote_commands.empty?
         run_now! ssh_cmd(remote_commands.join("; "))
        end

        puts "\n" if dep_config.get(:env) != 'test'
        self.commands = []
      end
    end

    def big_push!
      # TODO: The future of pushing stuff to the server
    end
  end
end

