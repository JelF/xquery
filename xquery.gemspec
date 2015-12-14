$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
require 'xquery/version'

Gem::Specification.new do |spec|
  spec.name = 'xquery'
  spec.version = XQuery::VERSION
  spec.authors = %w(jelf)
  spec.summary = <<-TXT.gsub('\A {4}', '')
    XQuery is designed to replace boring method call chains and allow to easier
    convert it in a builder classes
    see README.md for more information
  TXT

  spec.platform = 'java' if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'

  spec.homepage = 'https://github.com/JelF/xquery'
  spec.license = 'WTFPL'

  spec.description = File.read(File.expand_path('../README.md', __FILE__))
  spec.email = %W(begdory4+#{spec.name}@gmail.com)
  spec.files = `git ls-files -z`.split("\x0").grep(%r{\Alib/.+\.rb\z})

  spec.require_paths = %w(lib)

  spec.add_dependency 'activesupport', '~> 4.0'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rspec', '~> 3.3'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rake', '~> 10.4'
  spec.add_development_dependency 'rubocop', '~> 0.35'
  spec.add_development_dependency 'yard', '~> 0.8'
  spec.add_development_dependency 'simplecov', '~> 0.11'
end
