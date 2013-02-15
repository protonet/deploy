require "#{File.dirname(File.expand_path(__FILE__))}/spec_helper"

describe "Deploy" do
  before {@summary = "This is a test summary"}

  it "fails if the task to be executed is not passed in" do
    confirm { ::Deploy::Setup.init({:task => '', :test => true}, @summary) == 1 }
  end

  it 'requires a minamin amount of data in a task' do
    options = {:task => 'merge_branch', :test => true}

    confirm do
      ::Deploy::Setup.init(options, @summary) == 1
    end

    confirm do
      dep_config.set(:git_from_branch, :master)
      dep_config.set(:git_to_branch, :staging)
      ::Deploy::Setup.init(options, @summary) == 0
    end
  end
end

