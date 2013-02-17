# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "deploy/version"
require "date"

Gem::Specification.new do |s|
  s.name                        = "deploy"
  s.version                     = Deploy::VERSION
  s.platform                    = Gem::Platform::RUBY
  s.authors                     = ["Philip MacIver", "Ali Jelveh"]
  s.email                       = ["philip@ivercore.com"]
  s.homepage                    = "https://github.com/protonet/deploy"
  s.summary                     = %q{Deployment made more plain}
  s.description                 = %q{Deployment made more plain}
  s.date                        = Date.today.to_s

  s.rubyforge_project           = "deploy"

  s.add_development_dependency  "rake"
  s.add_development_dependency  "minitest"
  s.add_development_dependency  "minitest-reporters"
  s.add_development_dependency  "simplecov"
  s.add_development_dependency  "activesupport"
  s.add_development_dependency  "wrong"

  s.add_runtime_dependency      "simpleconfig"
  s.add_runtime_dependency      "erubis"
  s.add_runtime_dependency      "pony"

  s.files                       = `git ls-files`.split("\n")
  s.test_files                  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables                 = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths               = ["lib"]
end

