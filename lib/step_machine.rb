# encoding: utf-8

require "step_machine/version"
require "step_machine/step"

module StepMachine

  module ClassMethods
  end

  module InstanceMethods

    def step(name, &block)
      @steps ||= []

      unless step = get_step(name)
        step = create_step(name)  
      end

      step.block = block if block
      @first_step ||= step

      step
    end

    private

    def get_step(name)
      @steps.find { |step| step.name == name }
    end

    def create_step(name)
      step = Step.new(name)
      @steps << step
      @steps[-2].next_step = step if @steps.length > 1
      step
    end

    def run_steps
      step = @first_step

      while step
        break unless step.perform
        step = step.next
      end
    end

  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
