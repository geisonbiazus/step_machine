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

    def add_step(name, param=nil, options=nil, block)
      step = Step.new
      step.name = name
      step.param = param
      step.options = options
      step.block = block.instance_of?(String) ? eval(block) : block
      raise ArgumentError, "invalid block parameter of method add_step(#{name}, #{param}, #{block})" unless step.block.instance_of?(Proc)
      queue << step
    end

    def step(name, param=nil, options=nil, &block)
      add_step(name, param, options, block)
    end

    # Execute one step of queue
    def walk(options ={})
      position = options[:position] || nil
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
        step = walk :position => position
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



# class Hdi
#   include StepMachine

#   attr_accessor :agent

#   def initialize
#     self.agent = Mechanize.new
#     define_steps
#   end

#   def define_steps

#     step :dados_segurado do
#       agent.post("", "")
#     end.validate { |step| step.result.body.match(/cod_cotacao/) }

#     step :pessoa_fisica do
#       agent.post("", "")
#     end.validate { |step| step.result.code == '200' }

#     step :pessoa_juridica do
#       agent.post("", "")
#     end.validate { |step| step.result.code == '200' }

#     step[:dados_segurado].next_step = @cotacao.cliente.pessoa == 'F' ? steps[:pessoa_fisica] : steps[:pessoa_juridica]

#     step :pesquisar_veiculo do
#       veiculos = agent.post("", "").scan("")
#     end.validate { |step| step.result.code == '200' }.validate(/ul li/).next_step do |step|
#       return :selecionar_veiculo if step.result.search('ul li')
#       return :calcular
#     end
 
#     step :selecionar_veiculo do
#       veiculo = aproximado(veiculos, @cotacao.veiculo.descricao)
#       agent.post("", "")
#     end

#     step :calcular do
#       agent.post("", "")
#     end

#     step[:calcular].validate do |step| 
#       raise ValidacaoSeguradoraError unless step.result.search("#cod_cotacao") 
#     end

#     step[:calcular].success do |step| 
#       preco.cod_cotacao = step.result.search("#cod_cotacao")
#     end

#     step[:pesquisar_veiculo].next_step do |step|
#       return step[:selecionar_veiculo] if step.result.search('ul li')
#       return step[:calcular]
#     end

#     on_step_failure :except => {:dados_segurado, :pesquisar_veiculo} do |step|
#       step.exception
#       step.result
#       mail
#     end

#     on_step_failure :only => {:dados_segurado, :pesquisar_veiculo} do
#       repeat_step if condition
#       go_to_step :calcular if condition
#       go_to_next_step if condition
#       go_to_step(:calcular).and_stop if condition
#     end

#     walking
#   end
# end

# describe Hdi do

#   before :each do
#     @hdi.on_step_failure do |step|
#       p step
#     end
#   end

#   it do    

#     @hdi.cotar
#     @hdi.step_result.should be_success

#   end

# end

