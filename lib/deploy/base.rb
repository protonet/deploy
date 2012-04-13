module Deploy
  class Base

    include ::Deploy::DSL
    include ::Deploy::RemoteCommands
    include ::Deploy::Process

  end
end

