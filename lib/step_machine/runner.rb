module StepMachine
	class Runner

		attr_accessor :first_step

		def initialize
			@steps = []
			@step_failures = []
			@before_each_step = []
			@after_each_step = []
		end

		def step(name, &block)
			unless step = get_step(name)
        step = create_step(name)  
      end

      step.block = block if block
      @first_step ||= step

      step
		end

		def on_step_failure(options = {}, &block)
			@step_failures << options.merge(:block => block)
		end

		def before_each_step(options = {}, &block)
			@before_each_step << options.merge(:block => block)
		end	

		def after_each_step(options = {}, &block)
			@after_each_step << options.merge(:block => block)
		end

		def run
			step = @first_step

      while step
      	execute_before_each_step(step)
        unless step.perform
          execute_step_failures(step)
          break
        end
      	execute_after_each_step(step)

        step = step.next
      end
		end

		private

		def execute_before_each_step(step)
			@before_each_step.each do |before|
				next if before.has_key?(:only) && !before[:only].include?(step.name)
				next if before.has_key?(:except) && before[:except].include?(step.name)
				before[:block].call(step)
			end
		end

		def execute_after_each_step(step)
			@after_each_step.each do |after|
				next if after.has_key?(:only) && !after[:only].include?(step.name)
				next if after.has_key?(:except) && after[:except].include?(step.name)
				after[:block].call(step)
			end
		end

    def execute_step_failures(step)
      @step_failures.each do |step_failure|
        next if step_failure.has_key?(:only) && !step_failure[:only].include?(step.name)
        next if step_failure.has_key?(:except) && step_failure[:except].include?(step.name)

        step_failure[:block].call(step)
      end
    end

    def get_step(name)
      @steps.find { |step| step.name == name }
    end

    def create_step(name)
      step = Step.new(name)
      @steps << step
      @steps[-2].next_step = step if @steps.length > 1
      step
    end
	end	
end