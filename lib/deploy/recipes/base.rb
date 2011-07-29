module Deploy
  module Recipes
    class Base

      include ::Deploy::Base
      include ::Deploy::RemoteCommands

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

        def actions
          @@actions ||= []
          @@actions
        end

        def run_actions(run_clazz)
          actions.each do |action|
            puts "\n*** #{action} ***" if should_i_do_it?
            run_clazz.send(action)
            status = run_clazz.push!
            run_clazz.send(:on_local_failure)  if dep_config.get(:local_status)  == false
            run_clazz.send(:on_remote_failure) if dep_config.get(:remote_status) == false
          end
        end

      end

    end
  end
end

