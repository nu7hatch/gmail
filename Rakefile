#!/usr/bin/env ruby

require 'rubygems'

begin
  require 'jeweler'
  
  Jeweler::Tasks.new do |gem|
    gem.name = "gmail"
    gem.summary = %Q{A Rubyesque interface to Gmail, with all the tools you'll need.}
    gem.description = <<-DESCR
      A Rubyesque interface to Gmail, with all the tools you'll need. Search, 
      read and send multipart emails; archive, mark as read/unread, delete emails; 
      and manage labels.
    DESCR
    gem.email = "kriss.kowalik@gmail.com"
    gem.homepage = "http://github.com/nu7hatch/gmail"
    gem.authors = ["BehindLogic", "Kriss 'nu7hatch' Kowalik"]
    gem.add_dependency 'mime', '>= 0.1'
    gem.add_dependency 'mail', '>= 2.2.1'
    gem.add_development_dependency 'rspec', '~> 2.0'
    gem.add_development_dependency 'mocha', '>= 0.9'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rspec_opts = %q[--colour --backtrace]
end

RSpec::Core::RakeTask.new(:rcov) do |t|
  t.rcov = true
  t.rspec_opts = %q[--colour --backtrace]
  t.rcov_opts = %q[--exclude "spec" --text-report]
end

task :spec => :check_dependencies
task :rcov => :check_dependencies
task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Ruby GMail #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
