require "spec_helper"

include StepMachine

describe "StepMachine" do

	before :each do
	end	

	describe "on step" do

		it "should create an instance of the runner" do
			step(:name) {}
			@step_machine_runner.should be_a(Runner)
		end

		it "should create an step with the given name and block" do

			block = proc { x + 1 }
			step = step(:name, &block)

			step.name.should == :name
			step.block.should == block
		end

	end

	describe "on run_steps" do
		it "should run the given steps" do
			step(:step) { 1 + 1}

			run_steps

			step(:step).result.should == 2
		end		
	end

	describe "callbacks" do

		it "on_step_failure should execute the given block if the step fails" do
		  step(:step_1){ }.validate{false}

		  x = 0
		  on_step_failure{x += 1}

		  run_steps

		  x.should == 1
		end

		it "should execute the given block before each step" do

		  step(:step_1){ }
		  step(:step_2){ }

		  x = 0
		  before_each_step {x += 1}

		  run_steps

		  x.should == 2
		end

		it "should execute the given block before each step" do

		  step(:step_1){ }
		  step(:step_2){ }

		  x = 0
		  after_each_step {x += 1}

		  run_steps

		  x.should == 2
		end

	end
end