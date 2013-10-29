require "spec_helper"

include StepMachine

describe "StepMachine" do

	before :each do
	end	

	describe "on step" do

		it "should create an step with the given name and block" do

			block = proc { x + 1 }

			step = step(:name, &block)

			step.name.should == :name
			step.block.should == block
		end

		it "should return the required step" do
			step_1 = step(:step_1) {}
			step_2 = step(:step_2) {}

			step(:step_1).should == step_1
		end

		it "should update the step with the last given block" do
			block = proc { x + 1 }

			step(:step_1) {}
			step(:step_1, &block)

			step(:step_1).block.should == block
		end

		it "should assign the next step automatically" do
			step_1 = step(:step_1) {}
			step_2 = step(:step_2) {}

			step_1.next_step.should == step_2
		end
	end

end