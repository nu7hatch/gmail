# -*- ruby -*-

$:.unshift(File.expand_path('../lib', __FILE__))
require 'gmail/version'

begin
  require 'ore/tasks'
  Ore::Tasks.new
rescue LoadError => e
  STDERR.puts e.message
  STDERR.puts "Run `gem install ore-tasks` to install 'ore/tasks'."
end

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  task :spec do
    abort 'Run `gem install rspec` to install RSpec'
  end
end

task :test => :spec
task :default => :test

begin 
  require 'metric_fu'
rescue LoadError => e
  STDERR.puts e.message
  STDERR.puts "Run `gem install metric_fu` to install Metric-Fu"
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Gmail for Ruby #{Gmail.version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
