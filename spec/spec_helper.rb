require 'rubygems'
require 'bundler/setup'
require 'simplecov'

# SimpleCov.start

Dir[File.expand_path("../../", __FILE__) + "/lib/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
	# Ativa output colorido
	config.color_enabled = true
end