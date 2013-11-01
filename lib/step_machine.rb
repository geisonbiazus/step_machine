# encoding: utf-8

require "step_machine/version"
require "step_machine/step"

module StepMachine

  module ClassMethods
  end

  module InstanceMethods

    def step(name, &block)
      @step_machine_runner ||= Runner.new
      @step_machine_runner.step(name, &block)
    end

    def on_step_failure(options = {}, &block)
      @step_machine_runner.on_step_failure(options, &block)
    end

    def run_steps
      @step_machine_runner.run
    end

    def first_step(step)
      @step_machine_runner.first_step = step
    end

  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
