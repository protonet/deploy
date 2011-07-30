module Deploy
  module Utils
    class Base

      include ::Deploy::Utils::RemoteCommands

      attr_accessor :commands

      @@appended_actions ||= []
      @@prepended_actions ||= []

      class << self

        def descriptions
          @@descriptions ||= []
        end

        def desc(method_name, description)
          descriptions << [method_name, description]
        end

        def all_descriptions
          descriptions.sort{|a,b| a.first <=> b.first}
        end

        def actions=(actions)
          @@actions = actions
        end

        def prepend_action(action, prepend_before = nil)
          @@prepended_actions << [action, prepend_before]
        end

        def append_action(action, apend_after = nil)
          @@appended_actions << [action, apend_after]
        end

        def actions
          @@actions ||= []
          @@actions
        end

        def merge_actions
          @@prepended_actions.each do |pa|
            if pa.last.nil?
              actions.insert(0,pa.first)
            else
              ind = actions.index(pa.last)
              ind.nil? ? actions.insert(0, pa.first) : actions.insert(ind,pa.first)
            end
          end

          @@appended_actions.each do |aa|
            if aa.last.nil?
              actions.insert(-1, aa.first)
            else
              ind = actions.index(aa.last)
              ind.nil? ? actions.insert(-1, aa.first) : actions.insert(ind + 1,aa.first)
            end
          end

        end

        def run_actions(run_clazz)
          merge_actions
          actions.each do |action|
            puts "\n*** #{action} ***" if verbose?
            run_clazz.send(action)
            status = run_clazz.push!
            run_clazz.send(:on_local_failure)  if should_i_do_it? && dep_config.get(:local_status)  == false
            run_clazz.send(:on_remote_failure) if should_i_do_it? && dep_config.get(:remote_status) == false
          end
        end
      end

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
        puts "EXECUTING: #{command}" if verbose?
        system command if should_i_do_it?
      end

      def run_now_with_return!(command)
        puts "EXECUTING: #{command}" if verbose?
        `#{command}` if should_i_do_it?
      end

      def push!(push_now = false)
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

          dep_config.set(:local_status,  run_now!(local_commands.join("; ")))           unless local_commands.empty?
          dep_config.set(:remote_status, run_now!(ssh_cmd(remote_commands.join("; ")))) unless remote_commands.empty?

          puts "\n" if should_i_do_it?
          self.commands = []
        end
      end

    end
  end
end

