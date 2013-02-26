require "#{File.dirname(File.expand_path(__FILE__))}/spec_helper"

describe "Deploy" do

  before do
    dep_config.set :deploy_root, "/var/www"
    dep_config.set :app_name,    "test"
    dep_config.set :shell,       "/bin/bash"

    @summary = "This is a test summary"
    @options = { :test => true }
  end

  it "fails if the task to be executed is not passed in" do
    confirm { ::Deploy::Setup.init({:tasks => '', :test => true}, @summary) == 1 }
  end

  it 'requires a minamin amount of data in a task' do
    options = {:tasks => 'merge_branch', :test => true}

    confirm do
      ::Deploy::Setup.init(options, @summary) == 1
    end

    confirm do
      dep_config.set(:git_from_branch, :master)
      dep_config.set(:git_to_branch, :staging)
      ::Deploy::Setup.init(options, @summary) == 0
    end
  end

  it "runs" do
    task_bundles.each do |tasks_name, tasks|
      tasks.each do |task|
        @options[:tasks] = task
        confirm { ::Deploy::Setup.init(@options, "") == 0 }
      end
    end
  end

  it "appends a task in the chain" do
    confirm { ::Deploy::Setup.init(@options.merge({:tasks => 'test'}), "") == 0 }
  end

  it "allows you to pass in parameters" do
    task_bundles.each do |tasks_name, tasks|
      tasks.each do |task|
        @options[:parameters] = "TEST1=test1,TEST2=test2"
        @options[:tasks]      = task

        ::Deploy::Setup.init(@options, "")

        confirm { dep_config.TEST1 == "test1" }
        confirm { dep_config.TEST2 == "test2" }
      end
    end
  end

  it "passes in more tasks to execute" do
  end

  it "passes in tasks not to execute" do
  end

end
