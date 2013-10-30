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

    def perform
      @result = block.call
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