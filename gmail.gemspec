# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'gmail/version'

Gem::Specification.new do |s|
  s.name        = "gmail"
  s.version     = Gmail.version
  s.authors     = ["Chris Kowalik"]
  s.email       = ["chris@nu7hat.ch"]
  s.homepage    = "https://github.com/nu7hatch/gmail"
  s.summary     = %q{A Rubyesque interface to Gmail, with all the tools you will need}
  s.description = %q{A Rubyesque interface to Gmail, with all the tools you will need.
  Search, read and send multipart emails; archive, mark as read/unread,
  delete emails; and manage labels.}

  s.rubyforge_project = "gmail"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_dependency("mime", ">= 0.1")
  s.add_dependency("mail", ">= 2.2.1")
  s.add_dependency("gmail_xoauth", ">= 0.3.0")
  s.add_development_dependency("bundler", ">= 1.0.0")
  s.add_development_dependency("rspec", "~> 2.0")
  s.add_development_dependency("mocha", ">= 0.9")
end
