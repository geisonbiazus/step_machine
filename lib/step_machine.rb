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

    def on_step_failure(options = {}, &block)
      @step_failures ||= []
      @step_failures << options.merge(:block => block)
    end

    def run_steps
      step = @first_step

      while step
        unless step.perform
          execute_step_failures(step)
          break
        end

        step = step.next
      end
    end

    private

    def execute_step_failures(step)
      if @step_failures
        @step_failures.each do |step_failure|
          next if step_failure.has_key?(:only) && !step_failure[:only].include?(step.name)
          next if step_failure.has_key?(:except) && step_failure[:except].include?(step.name)

          step_failure[:block].call(step)
        end
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

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
