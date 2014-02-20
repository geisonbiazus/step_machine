require "spec_helper"

describe StepMachine::Runner do

	before :each do
		@runner = StepMachine::Runner.new
	end	

	describe 'on group' do

		it "should create and return the group" do
			group = @runner.group(:group)

			group.should be_a(StepMachine::Group)
			group.name.should == :group
		end

		it "should return an existing group" do
			group = @runner.group(:group)

			expect(@runner.group(:group)).to eql(group)
		end

		it "should assign the first step defined as first step of group" do
			@runner.group(:group_1) do
				@runner.step(:step_1) {}
				@runner.step(:step_2) {}
			end

			@runner.group(:group_1).first_step.should == @runner.step(:step_1)
		end

		it "should create an step with the surrounding group" do
			@runner.group(:group_1) do
				@runner.step(:step_1) {}
			end

			@runner.group(:group_2) do
				@runner.step(:step_2) {}
			end

			@runner.step(:step_3) {}

			@runner.step(:step_1).group.name.should == :group_1
			@runner.step(:step_2).group.name.should == :group_2
			@runner.step(:step_3).group.should be_nil			
		end

		it "should assign a condition with group" do
		  block = proc {x + 1}
		  @runner.group(:group_1) do
		  	@runner.step(:step_2) {}
		  end.condition &block
		  expect(@runner.group(:group_1).condition_block).to eql(block)
		end

	end

	describe "on step" do

		it "should create an step with the given name and block" do

			block = proc { x + 1 }
			step = @runner.step(:name, &block)

			step.name.should == :name
			step.block.should == block
		end

		it "should return the required step" do
			step_1 = @runner.step(:step_1) {}
			step_2 = @runner.step(:step_2) {}

			@runner.step(:step_1).should == step_1
		end

		it "should update the step with the last given block" do
			block = proc { x + 1 }

			@runner.step(:step_1) {}
			@runner.step(:step_1, &block)

			@runner.step(:step_1).block.should == block
		end

		it "should assign the next step automatically" do
			step_1 = @runner.step(:step_1) {}
			step_2 = @runner.step(:step_2) {}

			step_1.next_step.should == step_2
		end

		it "should assign the first step automatically" do
			step_1 = @runner.step(:step_1) {}
			@runner.first_step.should == step_1

			step_2 = @runner.step(:step_2) {}
			@runner.first_step.should == step_1
		end
	end

	describe "on run" do
		it "should run the given step" do
			@runner.step(:step) { 1 + 1}

			@runner.run

			@runner.step(:step).result.should == 2
		end

		it "should run the steps based in the steps order" do
			x = 0

			@runner.step(:step_1) { x += 1 }
			@runner.step(:step_2) { x += 1 }

			@runner.run

			x.should == 2
		end

		it "should run the steps correctly wne the order is changed" do
			order = []

			block = proc { |s| order << s.name }

			@runner.step(:step_1, &block)
			@runner.step(:step_2, &block)
			@runner.step(:step_3, &block)

			@runner.step(:step_1).next_step = @runner.step(:step_3)
			@runner.step(:step_3).next_step = @runner.step(:step_2)
			@runner.step(:step_2).next_step = nil

			@runner.run

			order.should == [:step_1, :step_3, :step_2]
		end

		it "should run the steps correctly wne the order is changed" do
			order = []

			block = proc { |s| order << s.name }

			@runner.step(:step_1, &block)
			@runner.step(:step_2, &block)
			@runner.step(:step_3, &block)

			@runner.step(:step_1).next_step = @runner.step(:step_3)
			@runner.step(:step_3).next_step { @runner.step(:step_2) }
			@runner.step(:step_2).next_step = nil

			@runner.run

			order.should == [:step_1, :step_3, :step_2]
		end

		it "should start on the given first step" do
			order = []

			block = proc { |s| order << s.name }

			@runner.step(:step_1, &block)
			@runner.step(:step_2, &block)
			@runner.step(:step_3, &block)

			@runner.step(:step_1).next_step = @runner.step(:step_3)
			@runner.step(:step_3).next_step { @runner.step(:step_2) }
			@runner.step(:step_2).next_step = nil

			@runner.first_step = @runner.step(:step_2)

			@runner.run

			order.should == [:step_2]
		end

		it "should stop execution if a step fail" do
			order = []

			block = proc { |s| order << s.name }

			@runner.step(:step_1, &block)
			@runner.step(:step_2, &block)
			@runner.step(:step_3, &block).validate { false }

			@runner.step(:step_1).next_step = @runner.step(:step_3)
			@runner.step(:step_3).next_step { @runner.step(:step_2) }
			@runner.step(:step_2).next_step = nil

			@runner.run

			order.should == [:step_1, :step_3]
		end


		it "should store the failed step" do
			@runner.step(:step_1) {}
			@runner.step(:step_2) {}
			@runner.step(:step_3) {}.validate { false }

			@runner.step(:step_1).next_step = @runner.step(:step_3)
			@runner.step(:step_3).next_step { @runner.step(:step_2) }
			@runner.step(:step_2).next_step = nil

			@runner.run

			@runner.failed_step.should == @runner.step(:step_3)
		end

		it "should run only the steps of the given group" do
			order = []

			block = proc { |s| order << s.name }

			@runner.group :group do
				@runner.step(:step_1, &block)
				@runner.step(:step_2, &block)
			end
			@runner.step(:step_3, &block)

			@runner.run( :group => :group )

			order.should == [:step_1, :step_2]
		end

		it "should run the steps up to given step" do
			order = []
			block = proc { |s| order << s.name }
			@runner.step(:step_1, &block)
			@runner.step(:step_2, &block)
			@runner.step(:step_3, &block)
			@runner.run( :upto => :step_2 )
			order.should == [:step_1, :step_2]		  
		end

		it "should run the steps from given step" do
			order = []
			block = proc { |s| order << s.name }
			@runner.step(:step_1, &block)
			@runner.step(:step_2, &block)
			@runner.step(:step_3, &block)
			@runner.run( :from => :step_2 )
			order.should == [:step_2, :step_3]
		end

		it "should run the steps from step_2 upto step_3" do
			order = []
			block = proc { |s| order << s.name }
			@runner.step(:step_1, &block)
			@runner.step(:step_2, &block)
			@runner.step(:step_3, &block)
			@runner.step(:step_4, &block)
			@runner.run( :from => :step_2, :upto => :step_3 )
			order.should == [:step_2, :step_3]
		end

		it "should evaluate the group condition" do
			order = []
			block = proc { |s| order << s.name }
			
			@runner.step(:step_1, &block)
			
			@runner.group :group do
				@runner.step(:step_2, &block)
				@runner.step(:step_3, &block)
			end.condition { false }
			
			@runner.step(:step_4, &block)

			@runner.run
			
			expect(order).to eql([:step_1, :step_4])
		end

	end

	describe "on_step_failure" do

		it "it should execute the given block if the step fails" do
		  @runner.step(:step_1){ }.validate{false}

		  x = 0
		  @runner.on_step_failure{x += 1}

		  @runner.run

		  x.should == 1
		end

		it "it should execute more than one blocks if the step fails" do
		  @runner.step(:step_1){ }.validate{false}

		  x = 0
		  @runner.on_step_failure{x += 1}
		  @runner.on_step_failure{x += 2}

		  @runner.run
		  
		  x.should == 3
		end

		it "should pass the failed step to the block" do 
		  step_1 = @runner.step(:step_1){ }.validate{false}

		  x = 0
		  @runner.on_step_failure do |f|
		  	f.step.should == step_1
		  end

		  @runner.run
		end

		it "should execute the on step failure block only on the given steps" do
			@runner.step(:step_1) {}.validate {false}
			@runner.step(:step_2) {}.validate {false}

			step_failed = nil
			@runner.on_step_failure :only => [:step_1] {|f| step_failed = f.step.name}
			@runner.run
			step_failed.should == :step_1

			@runner.first_step = step(:step_2)
			step_failed = nil
			@runner.run
			step_failed.should == nil
		end

		it "should execute the on step failure block excluding on the given steps" do
			@runner.step(:step_1) {}.validate {false}
			@runner.step(:step_2) {}.validate {false}

			step_failed = nil
			@runner.on_step_failure :except => [:step_2] {|f| step_failed = f.step.name}
			@runner.run
			step_failed.should == :step_1

			@runner.first_step = step(:step_2)
			step_failed = nil
			@runner.run
			step_failed.should == nil
		end

		it "should go to the specified step" do
			order = []

			block = proc {|s| order << s.name}

			@runner.step(:step_1, &block).validate {false}
			@runner.step(:step_2, &block)

			@runner.on_step_failure do |treatment|
				treatment.go_to :step_2
			end

			@runner.run

			order.should == [:step_1, :step_2]
			@runner.status.should == :success
		end

		it "should repeat the failed step" do
			order = []
			count = 0

			block = proc {|s| order << s.name}

			@runner.step(:step_1, &block).validate {false}
			@runner.step(:step_2, &block)

			@runner.on_step_failure do |f|
				f.repeat if count == 0
				count += 1
			end

			@runner.run

			order.should == [:step_1, :step_1]
			@runner.status.should == :failure
		end

		it "should ignore the failure and continue" do
			order = []			

			block = proc {|s| order << s.name}

			@runner.step(:step_1, &block).validate {false}
			@runner.step(:step_2, &block)

			@runner.on_step_failure do |f|
				f.continue
			end

			@runner.run

			order.should == [:step_1, :step_2]
			@runner.status.should == :success
		end


		it "should restart the process" do
			order = []			
			count = 0

			block = proc {|s| order << s.name}

			@runner.step(:step_1, &block)
			@runner.step(:step_2, &block).validate do |s|
				count += 1
				count > 1
			end
			@runner.step(:step_3, &block)

			@runner.on_step_failure do |f|
				f.restart
			end

			@runner.run

			order.should == [:step_1, :step_2, :step_1, :step_2, :step_3]
			@runner.status.should == :success
		end

		it "should restart the process 2 times" do
			order = []			

			block = proc {|s| order << s.name}

			@runner.step(:step_1, &block)
			@runner.step(:step_2, &block).validate { false }
			@runner.step(:step_3, &block)

			@runner.on_step_failure do |f|
				f.restart.times(2)
			end

			@runner.run

			order.should == [:step_1, :step_2, :step_1, :step_2, :step_1, :step_2]
			@runner.times_to_repeat.should == -1
			@runner.status.should == :failure
		end

		it "should repeat step 2 times" do
			order = []			

			block = proc {|s| order << s.name}

			@runner.step(:step_1, &block)
			@runner.step(:step_2, &block).validate { false }
			@runner.step(:step_3, &block)

			@runner.on_step_failure do |f|
				f.repeat.times(2)
			end

			@runner.run

			order.should == [:step_1, :step_2, :step_2, :step_2]
			@runner.times_to_repeat.should == -1
			@runner.status.should == :failure
		end

		it "it should execute failure when has errors message on step" do
		  @runner.step(:step_1_errors){x=1}.validate {|step| step.errors << 'errors' }		
		  x = 0
		  @runner.on_step_failure{x += 1}
		  @runner.on_step_failure{x += 2}

		  @runner.run
		  
		  x.should == 3
		end

	end

	describe "before each step" do
		it "should execute the block given" do
			executed = []

			@runner.step(:step_1) {}
			@runner.step(:step_2) {}

			@runner.before_each_step {|s| executed << s.name}
			@runner.run

			executed.should == [:step_1, :step_2]
		end

		it "should execute the block given only in the given steps" do
			executed = []

			@runner.step(:step_1) {}
			@runner.step(:step_2) {}

			@runner.before_each_step :only => [:step_2] {|s| executed << s.name}
			@runner.run

			executed.should == [:step_2]
		end

		it "should execute the block given except in the given steps" do
			executed = []

			@runner.step(:step_1) {}
			@runner.step(:step_2) {}

			@runner.before_each_step :except => [:step_2] {|s| executed << s.name}
			@runner.run

			executed.should == [:step_1]
		end
	end

	describe "after each step" do
		it "should execute the block given" do
			executed = []

			@runner.step(:step_1) {}
			@runner.step(:step_2) {}

			@runner.after_each_step {|s| executed << s.name}
			@runner.run

			executed.should == [:step_1, :step_2]
		end

		it "should execute the block given only in the given steps" do
			executed = []

			@runner.step(:step_1) {}
			@runner.step(:step_2) {}

			@runner.after_each_step :only => [:step_2] {|s| executed << s.name}
			@runner.run

			executed.should == [:step_2]
		end

		it "should execute the block given except in the given steps" do
			executed = []

			@runner.step(:step_1) {}
			@runner.step(:step_2) {}

			@runner.after_each_step :except => [:step_2] {|s| executed << s.name}
			@runner.run

			executed.should == [:step_1]
		end
	end

	describe "result status" do

		it "should be success if all steps were performed" do
			@runner.step(:step_1) {}
			@runner.step(:step_2) {}

			@runner.run

			@runner.status.should == :success
		end

		it "should be failure if all steps were performed" do
			@runner.step(:step_1) {}
			@runner.step(:step_2) {}.validate {false}

			@runner.run

			@runner.status.should == :failure
		end

	end
end