# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "inform/version"

Gem::Specification.new do |s|
  s.name        = "inform"
  s.version     = Inform::VERSION
  s.authors     = ["Michael Pearson", "Chris Ottrey"]
  s.email       = ["mipearson@gmail.com", ""]
  s.homepage    = "https://github.com/playup/inform"
  s.summary     = %q{Interactive, colourised logging}
  s.description = s.summary

  s.add_development_dependency("rspec", "~> 2.6.0")
  s.add_development_dependency("rake")
  s.add_development_dependency("gem-release")

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
