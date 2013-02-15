require "#{File.dirname(File.expand_path(__FILE__))}/spec_helper"

describe "All Recipes" do

  before do
    dep_config.set :verbose,     false
    dep_config.set :deploy_root, "/var/www"
    dep_config.set :app_name,    "test"
    dep_config.set :shell,       "/bin/bash"

    @options = {
      :environment => 'test',
      :dry         => true,
      :quiet       => true,
      :test       => true,
    }
  end

  it "runs" do
    task_bundles.each do |tasks_name, tasks|
      tasks.each do |task|
        @options[:task] = task
        confirm { ::Deploy::Setup.init(@options, "") == 0 }
      end
    end
  end

  it "appends a task in the chain" do
    confirm { ::Deploy::Setup.init(@options.merge({:task => 'test'}), "") == 0 }
  end

  it "allows you to pass in parameters" do
    task_bundles.each do |tasks_name, tasks|
      tasks.each do |task|
        @options[:tasks_name] = tasks_name.to_s
        @options[:task] = task
        @options[:parameters] = "TEST1=test1,TEST2=test2"
        ::Deploy::Setup.init(@options, "")
        confirm { dep_config.TEST1 == "test1" }
        confirm { dep_config.TEST2 == "test2" }
      end
    end
  end

end