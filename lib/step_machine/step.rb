module StepMachine

  # = Objeto etapas
  # Objetivo da etapa é ser cada campo em que se adiciona informação.
  # Name:: Responsavel por identificara etapa atraves no 'name'
  # Block:: Armazenar um bloco 'Proc' a ser executado
  # Params:: Parametros passados para o bloco
  # Result:: Resultado da execução do block. Usar como conferência do valor setado
  class Step
    attr_accessor :name, :param, :block, :result

    def error?
      @error ||= false
    end

    def error=(opt)
      @error = opt
    end
  end
	
end