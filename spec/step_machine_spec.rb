require "spec_helper"

include StepMachine

describe "StepMachine" do

	before :each do
	end

	describe "when enqueue" do

		it "should create an instance of step" do
			step = Step.new
			step.should be_an_instance_of StepMachine::Step
		end

		it "should add step with block do..end and {}" do
			step('name', 'value param') do |param|
				param
			end
			step('name', 'value param') { |param| param }
			queue.count.should == 2
		end

		it "should add step with block and validate block param" do
			expect { add_step_by_block('name', 'param')}.to raise_error
		end

		it "should add step to queue" do
			add_step("Step 1", "params 1", proc {"block"})
			add_step("Step 2", "params 2", proc {"block"})
			add_step("Step 3", proc {"block"})
			queue.count.should equal(3)
		end

		it "should validate object proc of block attribute" do
			add_step("Step 1", "params 1", proc {"block"})
			queue[0].block.should be_an_instance_of Proc
			expect{ add_step("Step 1", "params 1", "non proc") }.to raise_error
			queue.count.should equal 1
		end

		it "should validate object proc of block attribute when passed proc in string format" do
			add_step("Step 1", "params 1", %{proc {"block"}})
			queue.count.should equal 1
			expect { add_step("Step 1", "params 1", %{non block string}) }.to raise_error
			queue.count.should equal 1
		end

		it "should add in queue_failed if failed execution" do
			add_step("Step 1", "params 1", proc { raise "Forced Error" })
			walk.error?.should be_true
			queue_failed.count.should equal 1
		end

		it "should excecute the next step of queue" do
			add_step("Step 1", "params 1", proc {"block"})
			queue.count.should equal 1
			walk
			queue.count.should equal 0
		end

		it "should add in queue_completed if correct execution" do
			add_step("Step 1", "params 1", proc { "block" })
			walk
			queue_completed.count.should equal 1
		end

		it "the queues should be empty to initialize" do
			queue.should_not be nil
			queue_completed.should_not be nil
		end
	end

	describe "when use queue" do

		it "should execute all steps of queue" do
			add_step("Step 1", "params 1", proc { "block" })
			add_step("Step 2", "params 2", proc { "block" })
			add_step("Step 3", "params 3", proc { "block" })
			walking
			queue.count.should equal 0
		end

		it "should execute one step of queu" do
			add_step("Step 1", "params 1", proc { "block 1" })
			add_step("Step 2", "params 2", proc { "block 2" })
			walk
			queue.count.should == 1
			queue_completed.count.should == 1
		end

		it "should execute all steps of queue until first error" do
			add_step("Step 1", "params 1", proc { "block" })
			add_step("Step 2", "params 2", proc { raise "first error" })
			add_step("Step 3", "params 3", proc { "block" })
			walking
			queue.count.should equal 1
			queue_completed.count.should equal 1
			queue_failed.count.should equal 1
		end

		it "should execute next step and return de current step" do
			add_step("Step 1", proc { "block 1" })
			walk.should be_an_instance_of Step
		end

		it "should execute all steps of queue until first error, using block and return current step" do
			add_step("Step in queue_completed", proc { "block 1" })
			add_step("Step in queue_failed", proc { raise "force exception" })
			add_step("Step in queue", proc { "block 3" })
			walking do |step|
				step.should be_an_instance_of Step
				step.error?.should be_true if step.name == "Step in queue_failed"
				step.error?.should be_false if step.name != "Step in queue_failed"
			end
			queue.count.should equal 1
			queue_completed.count.should equal 1
			queue_failed.count.should equal 1
		end

		it "should execute all steps and field value must be equal field result " do
			add_step("Step in queue_completed", "value_result" , proc { "value_result" })
			add_step("Step in queue_completed", "block 1", proc { "block 1" })
			walking do |step|
				step.result.should == step.param
			end
		end

		it "should stop if walking and then try walk" do
			step("Step 1", "value 1") { "value 1" }
			step("Step 2", "value 2") { "value 2" }
			walking
			queue.count.should == 0
			walk.should == nil
		end

		it "should stop walking if walk return nil value" do
			step("Step 1", "value 1") { "value 1" }
			queue << nil
			step("Step 3", "value 3") { "value 3" }
			queue.count.should == 3
			walking
			queue.count.should == 2
		end

		it "should clean queue, queue_completed, queue_failed if call clear_queue" do
			queue << 1
			queue_failed << 1
			queue_completed << 1
			clear_queues
			queue.empty?.should be_true
			queue_failed.empty?.should be_true
			queue_completed.empty?.should be_true
		end

		it "should walk just epecified step" do
			step("Step 1", "value 1") { "value 1" }
			step("Step 2", "value 2") { "value 2" }
			step("Step 3", "value 3") { "value 3" }
			walk 2
			queue_completed.first.name.should == "Step 2"		  
		end

		it "should return nil if invalid epecified step" do
			step("Step 1", "value 1") { "value 1" }
			step("Step 2", "value 2") { "value 2" }
			step("Step 3", "value 3") { "value 3" }
			walk(0).should == nil
			queue_completed.should have(0).items
			walk(4).should == nil
			queue_completed.should have(0).items
		end

		it "should walking queue from seccond position of queue to end" do
			step("Step 1", "value 1") { "value 1" }
			step("Step 2", "value 2") { "value 2" }
			step("Step 3", "value 3") { "value 3" }
			walking :position => 2
			queue_completed.should have(2).items
		end

	end

	describe "When use goup of stpes" do

		it "should add step with group and the group must be a symbol" do
		  pending
		end

	  it "should walking only in specified group" do
			pending "Only test was implemented"
			step("Step 1", "value 1", :group => :goup_1) { "value 1" }
			step("Step 2", "value 2", :group => :goup_1) { "value 2" }
			step("Step 3", "value 3", :group => :goup_2) { "value 3" }
			walking :group => :group_1
			queue_completed.should have(2).items	    
			queue.should have(1).items	    
	  end
	end

end