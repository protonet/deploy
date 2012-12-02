module Deploy
  module Process

    def self.included(base)
      base.class_eval do

        def self.process_queue
          self.merge_actions
          self.actions.each do |action|
            puts "\n*** #{action} ***" if verbose?
            send(action)
            status = push!
          end
          self.actions = []
        end

        def self.queue(actions)
          if actions.is_a?(Array)
            self.actions = self.actions + actions
          else
            self.actions << actions
          end
        end

        def self.merge_actions
          self.prepended_actions.each do |pa|
            if pa.last.nil?
              self.actions.insert(0,pa.first)
            else
              ind = self.actions.index(pa.last)
              ind.nil? ? self.actions.insert(0, pa.first) : self.actions.insert(ind,pa.first)
            end
          end

          self.appended_actions.each do |aa|
            if aa.last.nil?
              self.actions.insert(-1, aa.first)
            else
              ind = self.actions.index(aa.last)
              ind.nil? ? self.actions.insert(-1, aa.first) : self.actions.insert(ind + 1,aa.first)
            end
          end
        end

        def self.remote(command)
          self.commands << [:remote, command]
        end

        def self.local(command)
          self.commands << [:local, command]
        end

        def self.ssh_cmd(commands)
          cmd = "ssh "
          cmd << "#{dep_config.extra_ssh_options} " if dep_config.exists?(:extra_ssh_options) && dep_config.extra_ssh_options
          cmd << "#{dep_config.username}@#{dep_config.remote} "
          cmd << "'"
          cmd << "#{dep_config.after_login}; " if dep_config.exists?(:after_login) && dep_config.after_login
          cmd << "#{commands}"
          cmd << "'"
        end

        def self.run_now!(command)
          puts "EXECUTING: #{command}" if verbose?
          system command if should_i_do_it?
        end

        def self.run_now_with_return!(command)
          puts "EXECUTING: #{command}" if verbose?
          `#{command}` if should_i_do_it?
        end

        def self.push!(push_now = false)
          unless self.commands.empty?
            local_commands  = []
            remote_commands = []

            #TODO: Need tests to make sure local and remote work the way they are supposed to
            self.commands.each do |command|
              if command.first == :local
                puts "LOCAL: #{command.last}" if verbose?
                local_commands << command.last
              elsif command.first == :remote
                puts "REMOTE: #{command.last}" if verbose?
                remote_commands << command.last
              end
            end

            run_now!(local_commands.join("; "))           unless local_commands.empty?
            run_now!(ssh_cmd(remote_commands.join("; "))) unless remote_commands.empty?

            puts "\n" if should_i_do_it?
            self.commands = []
          end
        end
      end
    end
  end
end
