$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
require 'xquery/version'

Gem::Specification.new do |spec|
  spec.name = 'xquery'
  spec.version = XQuery::VERSION
  spec.authors = %w(jelf)
  spec.email = %W(begdory4+#{spec.name}@gmail.com)

  spec.files = Dir["#{__FILE__}/../lib"]
  spec.require_paths = %w(lib)

  spec.add_runtime_dependency 'activesupport'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rspec', '~> 3.3'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'yard'
end
