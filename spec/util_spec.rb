require "#{File.dirname(File.expand_path(__FILE__))}/spec_helper"

describe "Support" do

  it "should return a camelized word" do
    ::Deploy::Util.camelize("test_test_test_test").should.equal("TestTestTestTest")
  end

  it 'gets the recipe from the environment receipe file' do
    Deploy::Util.parse_for("#{File.dirname(File.expand_path(__FILE__))}/deploy/recipes/test.rb", :recipe).should == :padrino_data_mapper
  end
end