# encoding: utf-8

require "step_machine/version"
require "step_machine/step"

module StepMachine

  module ClassMethods
  end

  module InstanceMethods

    def clear_queues
      @queue = []
      @queue_failed = []
      @queue_completed = []
    end

    # Fila para execução
    def queue
      @queue ||= []
    end

    # Fila das execuções completadas
    def queue_completed
      @queue_completed ||= []
    end

    # Fila das execuções com falhadas
    def queue_failed
      @queue_failed ||= []
    end

    def add_step(name, param=nil, block)
      step = Step.new
      step.name = name
      step.param = param
      step.block = block.instance_of?(String) ? eval(block) : block
      raise ArgumentError, "invalid block parameter of method add_step(#{name}, #{param}, #{block})" unless step.block.instance_of?(Proc)
      queue << step
    end

    def step(name, param=nil, &block)
      add_step(name, param, block)
    end

    # Execute one step of queue
    def walk(position = nil)      
      return nil if (position && (position-1 < 0 || position-1 > queue.count))
      current_step = queue[position-1] if position
      return nil if (position && !current_step)
      current_step = queue.first unless position

      step = queue.delete(current_step) || (return nil)      
      begin
        step.result = step.block.call(step.param)
        queue_completed << step
      rescue Exception => e
        step.result = e.message
        step.error = true
        queue_failed << step
      end
      step
    end

    # Execute all steps of queue until first error
    def walking(options = {})
      position = options[:position] || 1
      while queue.count >= position
        step = walk position
        yield(step) if block_given?
        break if (step.nil? || step.error?)
      end
    end

  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end