# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'step_machine/version'

Gem::Specification.new do |spec|
  spec.name          = "step_machine"
  spec.version       = StepMachine::VERSION
  spec.authors       = ["Rafael Vettori"]
  spec.email         = ["rafael.vettori@gmail.com"]
  spec.description   = %q{When you want execute lazzy block commands, you need use this gem}
  spec.summary       = %q{Gem to standardize the of any block execution}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
