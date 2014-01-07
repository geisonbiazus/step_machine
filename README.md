# StepMachine

step_machine is a simple gem for executing code based in steps. Each step can be validated and if a step fails, the execution is aborted. 

## Installation

Add this line to your application's Gemfile:

    gem 'step_machine', git: git@bitbucket.org:geisonbiazus/step_machine.git

And then execute:

    $ bundle

## Usage

## Creating and running steps:
	include StepMachine
	
	step(:step_1) do
		# code for step 1
	end
	
	step(:step_2) do
		# code for step 2
	end
	
	run_steps

This code will run the steps in the created order

## Changing the execution order

	step(:step_1).next_step = step(:step_2)

or:

	step(:step_1).next_step do
		step(:step_2)
	end

## Validating steps

	step(:step_1).validate do |step|
		step.result == "OK"
	end
	
	step(step_1).validate(/^OK/)
	
	step(step_1).validate('OK')

## Callbacks

	on_step_failure do |f|
		f.go_to :step_2		
	end
	
	on_step_failure :only => [:step_2] do |f|
		f.restart
	end
	
	on_step_failure :except => [:step_1] do |f|
		if contition
			f.repeat
		else
			f.continue
		end
	end
	
	before_each_step do |step|
		# code
	end
	
	after_each_step do |step|
		# code
	end

## Executing code if a step runs successful

	step(:step_1).success do |step|
		# code
	end

## Conditional Steps

	step(:step_1).condition do 
		true
	end

## Executing a step depending on other step condition

	step(:step_2) do
		# code
	end.condition do 
		step(:step_1).performed?
	end

## Grouping steps

	group :group_1 do

		step :step_1 do
			#code
		end

		step :step_2 do
			#code
		end

	end

	step :step_3 do
		#code
	end

	run_steps(:group_1) # only the steps 1 and 2 will be performed

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
