module StepMachine
	class Runner

		attr_accessor :first_step, :continue, :next_step, :times_to_repeat, :repeat_what
		attr_reader :status, :failed_step

		def initialize
			@steps = []
      @groups = []
			@failure_treatments = []
			@before_each_step = []
			@after_each_step = []	
			@times_to_repeat = -1
		end

		def step(name, &block)
  		step = get_step(name) || create_step(name)  
      step.block = block if block      
      @first_step ||= step
      @next_step ||= @first_step

      step
		end

    def group(name)
      @current_group = group = @groups.detect {|g| g.name == name} || create_group(name)    
      yield if block_given?
      @current_group = nil
      group
    end

		def on_step_failure(options = {}, &block)			
			@failure_treatments << FailureTreatment.new(self, block, options)
		end

		def before_each_step(options = {}, &block)
			@before_each_step << options.merge(:block => block)
		end	

		def after_each_step(options = {}, &block)
			@after_each_step << options.merge(:block => block)
		end

		def first_step=(step)
			@next_step = @first_step = step
		end

		def run(group_name = nil)
      group = group_name ? group(group_name) : nil

      if group 
        if !@first_group_step
          @next_step = group.first_step
          @first_group_step = true
        end

        return if @next_step.group != group
      end

      @continue = nil
			step = @next_step

			@status ||= :success
      
      execute_before_each_step(step)

      unless step.perform      	
        @failed_step = step

        return repeat if repeat?        

        execute_step_failures(step)

        return run if @continue
        @status = :failure
        return
      end
      execute_after_each_step(step)
      
      run(group_name) if @next_step = step.next
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
      @failure_treatments.each do |failure_treatment|
      	failure_treatment.treat(step)        
      end
    end

    def get_step(name)
      @steps.find { |step| step.name == name }
    end

    def create_step(name)
      step = Step.new(name)
      step.group = @current_group
      @current_group.first_step ||= step if @current_group
      @steps << step
      @steps[-2].next_step = step if @steps.length > 1
      step
    end

    def create_group(name)
      group = Group.new(name)
      @groups << group
      group
    end

    def repeat?
    	@times_to_repeat >= 0
    end

    def repeat
    	@times_to_repeat -= 1

    	if @times_to_repeat == -1
        @status = :failure
        return 
      end

      @next_step = @repeat_what == :process ? @first_step : @failed_step
      return run
    end


    class FailureTreatment
    	attr_accessor :step
    	
    	def initialize(runner, block, options)
    		@runner = runner
    		@block = block
    		@options = options
    	end

    	def treat(step)    		
    		return if @options.has_key?(:only) && !@options[:only].include?(step.name)
        return if @options.has_key?(:except) && @options[:except].include?(step.name)
        @step = step

        @block.call(self)
    	end

    	def go_to(step_name)    		
    		@runner.next_step = @runner.step(step_name)
    		@runner.continue = true
    	end

    	def repeat
    		go_to(@step.name)
    		@runner.repeat_what = :step
    		self
    	end

    	def continue
    		go_to(@step.next.name)
    	end

    	def restart
    		go_to(@runner.first_step.name)
    		@runner.repeat_what = :process
    		self
    	end

    	def times(number)
    		@runner.times_to_repeat = number - 1
    	end

    end

	end	
end