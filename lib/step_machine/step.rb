module StepMachine

  class Step

    attr_accessor :name, :block, :next_step, :result

    def initialize(name)
      self.name = name
    end

    def perform
      self.result = block.call
    end
   
  end
	
end