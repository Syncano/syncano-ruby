# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'syncano/version'

Gem::Specification.new do |spec|
  spec.name          = 'syncano'
  spec.version       = Syncano::VERSION
  spec.authors       = ['Piotr Zadrożny', 'Maciej Lotkowski']
  spec.email         = ['piotr.zadrozny@mindpower.pl']
  spec.summary       = 'A Ruby client library for Syncano 4.0'
  spec.description   = 'A Ruby client that provides convenient interface for the Syncano api.'
  spec.homepage      = 'https://github.com/Syncano/syncano-ruby'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_dependency 'faraday', '~> 0.9'
  spec.add_dependency 'activesupport', '>= 4.0'
end
