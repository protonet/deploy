module Deploy
  module DSL

    def self.included(base)
      base.class_eval do

        def self.recipe(recipe); end

        def self.desc(method_name, description, public_scope = true, &block)
          if public_scope
            method_name = method_name.to_s

            duplicates = self.descriptions.each_with_index{|description, i| description.first == method_name ? i : nil }.compact
            duplicates.each{|i| self.descriptions.delete_at(i) }

            self.descriptions << [method_name.to_s, description]
          end

          define_singleton_method method_name.to_sym do
            class_eval(&block)
          end
        end

        def self.all_descriptions
          self.descriptions.sort{|a,b| a.first.to_s <=> b.first.to_s}
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

