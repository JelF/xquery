ROOT = Pathname.new(__FILE__).join('../../..')

require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.files = Dir[ROOT.join('lib/**/*.rb')]
  t.options = %w(--private)
end

require 'rubocop/rake_task'
RuboCop::RakeTask.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task default: %i(rubocop spec:coverage spec)

namespace :spec do
  coverage_root = ROOT.join('spec/coverage')
  desc "writes simplecov coverage in #{coverage_root}"
  task coverage: %i(simplecov spec)

  desc 'sets up simplecov'
  task :simplecov do
    ENV['COVERAGE_ROOT'] = coverage_root.to_s
  end

  desc 'runs spec with coverage and opens result'
  task :show_coverage do
    begin
      Rake::Task['spec:coverage'].execute
    rescue 'SystemExit'
      puts 'specs failed or coverage too low!'
    end

    require 'uri'
    exec 'xdg-open',
         URI.join('file:///', coverage_root.join('index.html').to_s).to_s
  end
end

namespace :doc do
  doc_root = ROOT.join('doc')

  desc 'clear all docs'
  task :clear do
    FileUtils.rm_r(doc_root) if doc_root.exist?
  end

  desc 'open doc'
  task open: :yard do
    require 'uri'
    exec 'xdg-open', URI.join('file:///', doc_root.join('index.html').to_s).to_s
  end
end
