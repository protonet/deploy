require "#{File.dirname(File.expand_path(__FILE__))}/spec_helper"

describe "String" do

  it "should return a camelized word" do
    ::Deploy::Utils::String.camelize("test_test_test_test").should.equal("TestTestTestTest")
  end
end
