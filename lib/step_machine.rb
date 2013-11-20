# encoding: utf-8

require "step_machine/version"
require "step_machine/group"
require "step_machine/step"
require "step_machine/runner"

module StepMachine

  module ClassMethods
  end

  module InstanceMethods

    def group(name, &block)
      @step_machine_runner ||= Runner.new
      @step_machine_runner.group(name, &block)
    end

    def step(name, &block)
      @step_machine_runner ||= Runner.new
      @step_machine_runner.step(name, &block)
    end

    def on_step_failure(options = {}, &block)
      @step_machine_runner.on_step_failure(options, &block)
    end

    def before_each_step(options = {}, &block)
      @step_machine_runner.before_each_step(options, &block)
    end

    def after_each_step(options = {}, &block)
      @step_machine_runner.after_each_step(options, &block)
    end

    def run_steps(group_name = nil)
      @step_machine_runner.run(group_name)
    end

    def first_step(step)
      @step_machine_runner.first_step = step
    end

    def run_status
      @step_machine_runner.status
    end

    def failed_step
      @step_machine_runner.failed_step
    end

  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
