module Deploy
  module DSL

    def self.included(base)
      base.class_eval do

        def self.recipe(recipe); end

        def self.desc(method_name, description, public_scope = true, &block)
          self.descriptions << [method_name, description] if public_scope

          define_singleton_method method_name.to_sym do
            class_eval(&block)
          end
        end

        def self.all_descriptions
          self.descriptions.sort{|a,b| a.to_a.first <=> b.to_a.first}
        end

        def self.prepend(action, prepend_before = nil)
          self.prepended_actions << [action, prepend_before]
        end

        def self.append(action, apend_after = nil)
          self.appended_actions << [action, apend_after]
        end

      end
    end
  end
end

