module Deploy
  class Base

    def self.cattr_accessor(*args)
      args.each do |method_name|
        define_singleton_method method_name.to_sym do
          class_eval("@@#{method_name} ||= nil")
        end

        define_singleton_method "#{method_name}=".to_sym do |value|
          class_eval("@@#{method_name} = #{value}")
        end
      end
    end

    cattr_accessor :actions,
      :prepended_actions,
      :appended_actions,
      :descriptions,
      :commands

    self.actions           ||= []
    self.prepended_actions ||= []
    self.appended_actions  ||= []
    self.descriptions      ||= []
    self.commands          ||= []

    include ::Deploy::DSL
    include ::Deploy::Process
    include ::Deploy::RemoteCommands
    include ::Deploy::CommonMethods

  end
end

