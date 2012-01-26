require "#{File.dirname(File.expand_path(__FILE__))}/spec_helper"

describe "Deploy" do
  it "fails if minimum amount of data is not passed in" do
    opts = [
     {:environment => ''},
     {:method      => ''},
   ]

    summary = "This is a test summary"

    opts.each do |opt|
      ::Deploy::Setup.init(opt,summary).should == 1
    end
  end
end

