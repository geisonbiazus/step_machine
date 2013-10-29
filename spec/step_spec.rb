require "spec_helper"

describe Step do

	before :each do
		@step = Step.new(:name)
		@step.block = proc { 1 + 1 }
	end

	it "should execute the block and store the result" do
		@step.perform
		@step.result.should == 2
	end

end