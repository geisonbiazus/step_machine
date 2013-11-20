module StepMachine

	class Group
		attr_accessor :name, :first_step

		def initialize(name)
			@name = name
		end

	end
end