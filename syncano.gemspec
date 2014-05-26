# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'syncano/version'

Gem::Specification.new do |spec|
  spec.name          = 'syncano'
  spec.version       = Syncano::VERSION
  spec.authors       = ['Piotr Zadrożny']
  spec.email         = ['piotr.zadrozny@mindpower.pl']
  spec.summary       = 'A Ruby client library for Syncano'
  spec.description   = 'A Ruby client that provides convenient interface for the Syncano api.'
  spec.homepage      = 'https://github.com/Syncano/syncano-ruby'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'jimson-client'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'multi_json', '~> 1.10'
  spec.add_dependency 'eventmachine'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'guard-rspec'
end
