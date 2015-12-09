ROOT = Pathname.new(__FILE__).join('../../..')

require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.files = Dir[ROOT.join('lib/**/*.rb')] # optional
  # t.options = ['--any', '--extra', '--opts'] # optional
  # t.stats_options = ['--list-undoc']         # optional
end

namespace :doc do
  doc_root = ROOT.join('doc')

  desc 'clear all docs'
  task :clear do
    FileUtils.rm_r(doc_root) if doc_root.exist?
  end

  desc 'open doc'
  task open: 'yard' do
    require 'uri'
    exec 'xdg-open', URI.join('file:///', doc_root.join('index.html').to_s).to_s
  end
end
