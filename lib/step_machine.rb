# encoding: utf-8

require "step_machine/version"
require "step_machine/step"

module StepMachine

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
  def walk
    step = queue.delete(queue.first)
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
  def walking
    while queue.first
      step = walk
      yield(step) if block_given?
      break if step.error?
    end
  end

end
