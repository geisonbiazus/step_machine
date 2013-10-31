module StepMachine

  class Step

    attr_accessor :name, :block, :next_step
    attr_reader :exception, :result, :validation

    def initialize(name)
      self.name = name
    end

    def validate(value = nil, &block)     
      @validation = block || value
    end

    def success(&block)
      @success = block
    end

    def next_step(&block)
      @next_step = block if block
      @next_step
    end

    def next
      return next_step.call(self) if next_step.is_a?(Proc)
      next_step
    end

    def perform
      @result = block.call(self)
      valid = valid?
      @success.call(self) if @success && valid
      valid
    rescue => e
      @exception = e
      false
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