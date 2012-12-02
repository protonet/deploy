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
    }
  end

  it "runs" do
    recipes.each do |recipe, recipe_methods|
      recipe_methods.each do |recipe_method|
        @options[:method] = recipe_method
        ::Deploy::Setup.init(@options, "").should == 0
      end
    end
  end

  it "appends a method in the chain" do
    ::Deploy::Setup.init(@options.merge({:method => 'test'}), "").should == 0
  end

  it "allows you to pass in parameters" do
    recipes.each do |recipe, recipe_methods|
      recipe_methods.each do |recipe_method|
        @options[:recipe] = recipe.to_s
        @options[:method] = recipe_method
        @options[:parameters] = "TEST1=test1,TEST2=test2"
        ::Deploy::Setup.init(@options, "")
        dep_config.TEST1.should == "test1"
        dep_config.TEST2.should == "test2"
      end
    end
  end



end

