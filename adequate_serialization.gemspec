# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'adequate_serialization/version'

Gem::Specification.new do |spec|
  spec.name          = 'adequate_serialization'
  spec.version       = AdequateSerialization::VERSION
  spec.authors       = ['Kevin Deisz']
  spec.email         = ['kevin.deisz@gmail.com']

  spec.summary       = 'Serializes objects adequately'
  spec.homepage      = 'https://github.com/CultureHQ/adequate_serialization'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'oj', '~> 3.10'

  spec.add_development_dependency 'bundler', '~> 2'
  spec.add_development_dependency 'bundler-audit', '~> 0.6'
  spec.add_development_dependency 'minitest', '~> 5'
  spec.add_development_dependency 'rack-test', '~> 1.1'
  spec.add_development_dependency 'rake', '~> 13'
  spec.add_development_dependency 'rubocop', '~> 1.18'
  spec.add_development_dependency 'simplecov', '~> 0.16'
end
