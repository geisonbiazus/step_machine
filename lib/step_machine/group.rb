module StepMachine

	class Group
		attr_accessor :name, :first_step
    attr_reader :condition_block

		def initialize(name)
			@name = name
		end

    def condition(&block)
      @condition_block = block if block      
      self
    end

	end
end