require "#{File.dirname(File.expand_path(__FILE__))}/spec_helper"

describe "Deploy" do
  before {@summary = "This is a test summary"}

  it "fails if the metod to be executed is not passed in" do
    confirm { ::Deploy::Setup.init({:method => '', :quiet => true, :dry => true}, @summary) == 1 }
  end

  it 'requires a minamin amount of data in a method' do
    options = {:method => 'merge_branch', :quiet => true, :dry => true}

    confirm do
      confirm_raises { ::Deploy::Setup.init(options, @summary) }
    end

    confirm do
      deny_raises do
        dep_config.set(:git_from_branch, :master)
        dep_config.set(:git_to_branch, :staging)
        ::Deploy::Setup.init(options, @summary)
      end
    end
  end
end

