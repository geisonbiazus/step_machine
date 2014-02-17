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

	describe "on group" do

		it "should create an group and assign to the steps" do
			group(:group) do
				step(:step_1)
			end

			step(:step_1).group.should == group(:group)
		end

	end

	describe "on run_steps" do
		it "should run the given steps" do
			step(:step) { 1 + 1}

			run_steps

			step(:step).result.should == 2
		end	

		it "should run the steps of the given group" do
			x = 0

			group(:group) do
				step(:step) { x += 1 }
			end
				
			step(:step_2) { x += 1 }

			run_steps({:group => :group})

			x.should == 1
		end	

		it "should run the steps up to given step" do
		  x = 0
		  step(:step_1) { x += 1 }
		  step(:step_2) { x += 1 }
		  step(:step_3) { x += 1 }

		  run_steps :upto => :step_2

		  x.should == 2
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

	it "should return the status on run_status" do
		step(:step_1){ }
	  step(:step_2){ }

	  run_steps

	  run_status.should == :success
	end

	it "should return the failed step" do
		step(:step_1){ }
	  step(:step_2){ }.validate {false}

	  run_steps

	  failed_step.should == step(:step_2)
	end
end