# -*- encoding: utf-8 -*-
require "./lib/momentarily/version"

Gem::Specification.new do |s|
  s.name        = "momentarily"
  s.version     = Momentarily::VERSION
  s.authors     = ["Joshua Siler"]
  s.email       = ["joshua.siler@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{A rails gem that allows you to briefly defer execution of tasks and return from requests faster.}
  s.description = %q{A rails gem that allows you to briefly defer execution of tasks and return from requests faster.}

  s.rubyforge_project = "momentarily"

  s.files         = ["lib/momentarily.rb", "lib/momentarily/version.rb","README.textile"]
  s.test_files    = ["test/test_momentarily.rb"]
#  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "thin"
  s.add_runtime_dependency "eventmachine"
  s.add_runtime_dependency "activerecord"
  s.add_runtime_dependency "activesupport"
end
