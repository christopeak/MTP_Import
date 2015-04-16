require_relative 'Project'

class MtpProject < Project

	def initalize
		@vars = ImportVariables.new
		#puts vars.vars.length
	end
	def get_vars
		@vars
	end
end

myProj = MtpProject.new
myProj.set_vars
puts myProj.vars
