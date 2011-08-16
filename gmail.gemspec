# -*- ruby -*-

$:.unshift(File.expand_path('../lib', __FILE__))
require 'gmail/version'

begin
  Ore::Specification.new do |gemspec|
    gemspec.version = Gmail.version
  end
rescue NameError
  begin
    require 'ore/specification'
    retry
  rescue LoadError
    STDERR.puts "The '#{__FILE__}' file requires Ore."
    STDERR.puts "Run `gem install ore-core` to install Ore."
  end
end
