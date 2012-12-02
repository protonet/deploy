require "#{File.dirname(File.expand_path(__FILE__))}/spec_helper"

describe "Support" do

  it "should return a camelized word" do
    ::Deploy::Util.camelize("test_test_test_test").should.equal("TestTestTestTest")
  end
end