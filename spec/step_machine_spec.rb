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

		it "should assign the first step automatically" do
			step_1 = step(:step_1) {}
			@first_step.should == step_1

			step_2 = step(:step_2) {}
			@first_step.should == step_1
		end
	end

	describe "on run_steps" do
		it "should run the given step" do
			step(:step) { 1 + 1}

			run_steps

			step(:step).result.should == 2
		end

		it "should run the steps based in the steps order" do
			x = 0

			step(:step_1) { x += 1 }
			step(:step_2) { x += 1 }

			run_steps

			x.should == 2
		end

		it "should run the steps correctly wne the order is changed" do
			order = []

			block = proc { |s| order << s.name }

			step(:step_1, &block)
			step(:step_2, &block)
			step(:step_3, &block)

			step(:step_1).next_step = step(:step_3)
			step(:step_3).next_step = step(:step_2)
			step(:step_2).next_step = nil

			run_steps

			order.should == [:step_1, :step_3, :step_2]
		end

		it "should run the steps correctly wne the order is changed" do
			order = []

			block = proc { |s| order << s.name }

			step(:step_1, &block)
			step(:step_2, &block)
			step(:step_3, &block)

			step(:step_1).next_step = step(:step_3)
			step(:step_3).next_step { step(:step_2) }
			step(:step_2).next_step = nil

			run_steps

			order.should == [:step_1, :step_3, :step_2]
		end

		it "should start on the given first step" do
			order = []

			block = proc { |s| order << s.name }

			step(:step_1, &block)
			step(:step_2, &block)
			step(:step_3, &block)

			step(:step_1).next_step = step(:step_3)
			step(:step_3).next_step { step(:step_2) }
			step(:step_2).next_step = nil

			@first_step = step(:step_2)

			run_steps

			order.should == [:step_2]
		end

		it "should stop execution if a step fail" do
			order = []

			block = proc { |s| order << s.name }

			step(:step_1, &block)
			step(:step_2, &block)
			step(:step_3, &block).validate { false }

			step(:step_1).next_step = step(:step_3)
			step(:step_3).next_step { step(:step_2) }
			step(:step_2).next_step = nil

			run_steps

			order.should == [:step_1, :step_3]
		end
	end

end