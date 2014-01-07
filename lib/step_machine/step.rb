module StepMachine

  class Step

    attr_accessor :name, :block, :next_step, :group
    attr_reader :exception, :result, :validation, :condition_block

    def initialize(name)
      self.name = name
    end

    def validate(value = nil, &block)     
      @validation = block || value
      self
    end

    def success(&block)
      @success = block
      self
    end

    def next_step(&block)
      @next_step = block if block
      @next_step
    end

    def condition(&block)
      @condition_block = block if block
      self
    end

    def next
      return next_step.call(self) if next_step.is_a?(Proc)
      next_step
    end

    def perform
      return true if condition_block && !condition_block.call
      @performed = true
      @result = block.call(self)
      valid = valid?
      @success.call(self) if @success && valid
      valid
    rescue => e
      @exception = e
      false
    end

    def performed?
      !!@performed
    end

    private

    def valid?
      if validation 
        return validation.call(self) if validation.is_a?(Proc)
        return result.match(validation) if validation.is_a?(Regexp)
        return validation == result
      end
      true
    end

   
  end
	
end