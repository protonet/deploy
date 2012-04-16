module Deploy
  module DSL

    def self.included(base)
      base.class_eval do

        @@actions           ||= []
        @@prepended_actions ||= []
        @@appended_actions  ||= []
        @@descriptions      ||= []

        def self.recipe(recipe); end

        def self.desc(method_name, description, public_scope = false, &block)
          @@descriptions << [method_name, description] if public_scope

          define_method method_name.to_sym do
            self.instance_eval(&block)
          end
        end

        def self.all_descriptions
          @@descriptions.sort{|a,b| a.first <=> b.first}
        end

        def self.prepend(action, prepend_before = nil)
          @@prepended_actions << [action, prepend_before]
        end

        def self.append(action, apend_after = nil)
          @@appended_actions << [action, apend_after]
        end

        def self.merge_actions
          @@prepended_actions.each do |pa|
            if pa.last.nil?
              @@actions.insert(0,pa.first)
            else
              ind = @@actions.index(pa.last)
              ind.nil? ? @@actions.insert(0, pa.first) : @@actions.insert(ind,pa.first)
            end
          end

          @@appended_actions.each do |aa|
            if aa.last.nil?
              @@actions.insert(-1, aa.first)
            else
              ind = @@actions.index(aa.last)
              ind.nil? ? @@actions.insert(-1, aa.first) : @@actions.insert(ind + 1,aa.first)
            end
          end
        end

      end
    end
  end
end

