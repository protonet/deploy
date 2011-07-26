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

    def run_now!(command)
      puts "EXECUTING: #{command}" if dep_config.get(:verbose)
      system command unless dep_config.get(:dry_run)
    end

    def push!
      unless self.commands.empty?
        all_commands = self.commands.map do |command|
          if command.first == :local
            puts "LOCAL: #{command.last}" if dep_config.get(:verbose)
            eval command.last
            nil
          elsif command.first == :remote
            puts "REMOTE: #{command.last}" if dep_config.get(:verbose)
            command.last
          end
        end

        all_commands = all_commands.compact.join("; ")

        cmd = "ssh "
        cmd << "#{dep_config.get(:extra_ssh_options)} " if dep_config.get(:extra_ssh_options)
        cmd << "#{dep_config.get(:username)}@#{dep_config.get(:remote)} "
        cmd << "'"
        cmd << "#{dep_config.get(:after_login)}; " if dep_config.get(:after_login)
        cmd << "#{all_commands}"
        cmd << "'"
        run_now! cmd
        puts "\n" if dep_config.get(:env) != 'test'
        self.commands = []
      end
    end
  end
end

