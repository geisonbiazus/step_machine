require "spec_helper"

describe Step do

	before :each do
		@step = Step.new(:name)
		@step.block = proc { 1 + 1 }
	end

	describe "Validate" do

		it "validate should assign a block validation to the step" do

			block = proc {|step| step.result = 2}

			@step.validate(&block)
			@step.validation.should == block
		end

		it "validate should return the step" do
			block = proc {|step| step.result = 2}

			@step.validate(&block).should == @step
		end

		it "success should return the step" do
			block = proc {|step| step.result = 2}

			@step.validate(&block).should == @step
		end

		it "should assign a value to validate the result of the step" do
			@step.validate(1)
			@step.validation.should == 1
		end

		it "should permit add errors on step in array format" do
			@step.errors.push('error')
			@step.errors.push('error 2')
			expect(@step.errors).to have(2).items
			expect(@step.errors).to be_a(Array)
		end

		it "should permit add errors on step in hash format" do
			@step.errors({})[:step] = 'step error'
			expect(@step.errors).to have(1).items				  
			expect(@step.errors).to be_a(Hash)			
		end

		it "should permit add errors on step in string format" do
			@step.errors("") << 'step error'
			expect(@step.errors).to eql('step error')
			expect(@step.errors).to be_a(String)			
		end

		it "should permit reset with formats: String, Array and Hash" do
			@step.errors("") << 'step error'
			expect(@step.errors).to be_a(String)					  
			@step.errors([]) << 'step error'
			expect(@step.errors).to be_a(Array)					  
			@step.errors({})[:step_n] = 'error'
			expect(@step.errors).to be_a(Hash)					  
		end

	end

	describe "next step" do
		it "should assign a block to the next_step" do
			block = proc {|step| }
			@step.next_step(&block)
			@step.next_step.should == block
		end
	end

	describe "condition" do
		it "should assign a condition block" do
			block = proc {}
			@step.condition(&block).should == @step
			@step.condition_block.should == block
		end
	end

	describe "next" do

		it "should return the next step" do
			next_step = Step.new(:step_2)

			@step.next_step = next_step
			@step.next.should == next_step
		end

		it "should return the next step evaluating the block" do
			next_step = Step.new(:step_2)

			@step.next_step do |s|
				s.should == @step
			end

			@step.next
		end

		it "should return the next step evaluating the block" do
			next_step = Step.new(:step_2)

			@step.next_step { next_step }
			@step.next.should == next_step
		end

	end

	describe "on perform" do

		it "should execute the block and store the result" do
			@step.perform
			@step.result.should == 2
		end

		it "should pass the step to the block" do
			@step.block = proc do |step|
				step.should == @step
			end

			@step.perform
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

		it "should return true if step was executed" do
			step_a = Step.new(:step_a)
			step_a.block = proc { "step_a" }
			step_a.should_not be_performed
			step_a.perform
			step_a.should be_performed
		end

		it "should evaluate the condition block to execute the step" do
			@step.condition { true }
			@step.perform
			@step.should be_performed
		end

		it "should not execute the step if the condition block is false" do
			@step.condition { false }
			@step.perform.should be_true
			@step.should_not be_performed
		end

		it "should not execute the step if the group condition block is false" do
			group = Group.new(:group_1)
			group.condition { false }
			@step.group = group
			expect(@step.perform).to be_true
			expect(@step).not_to be_performed
		end


	end

end