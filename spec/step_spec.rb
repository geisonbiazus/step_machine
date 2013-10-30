require "spec_helper"

describe Step do

	before :each do
		@step = Step.new(:name)
		@step.block = proc { 1 + 1 }
	end
	
	it "should assign a block validation to the step" do
		block = proc {|step| step.result = 2}

		@step.validate(&block)
		@step.validation.should == block
	end

	it "should assign a value to validate the result of the step" do
		@step.validate(1)
		@step.validation.should == 1
	end

	describe "on perform" do

		it "should execute the block and store the result" do
			@step.perform
			@step.result.should == 2
		end

		it "should evaluate the validation block" do
			@step.validate {|step| step.result == 1} # invalid
			@step.perform.should be_false 

			@step.validate {|step| step.result == 2} # valid
			@step.perform.should be_true 
		end

		it "should evaluate the validation value" do
			@step.validate(1) # invalid
			@step.perform.should be_false 

			@step.validate(2) # valid
			@step.perform.should be_true
		end

		it "should evaluate the validation regex" do
			@step.block = proc { "validation" }
			@step.validate(/^x/) # invalid
			@step.perform.should be_false 

			@step.validate(/n$/) # valid
			@step.perform.should be_true
		end

		it "should store the exception on step when raised" do
			@step.block = proc { raise ArgumentError }			
			@step.perform.should be_false 
			@step.exception.class.should == ArgumentError
		end

		it "should execute a success block" do
			x = 0		  
			@step.success {|step| x += 1 }
			x.should == 0
		  @step.perform
			x.should == 1
		end
	end

end