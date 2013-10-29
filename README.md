# StepMachine

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'step_machine'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install step_machine

## Usage

Include the StepMachine in your class and add steps using the 'step' method and then execute steps with 'walk/walking' method

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


class Hdi
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

#     before_each_step do
#     end
    
#     before_all_steps do
#     end

#     after_each_step do
#     end
    
#     after_all_steps do
#     end

#     run_steps
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

