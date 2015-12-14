require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'pry'
require 'active_support/all'

if ENV['COVERAGE_ROOT']
  require 'simplecov'
  SimpleCov.start do
    minimum_coverage 100
    coverage_dir ENV['COVERAGE_ROOT']
    add_group 'Library', 'lib'
  end
end

require 'xquery'
# require 'xquery/active_record'

RSpec.configure do |config|
end
