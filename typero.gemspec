require File.expand_path("../lib/typero/version", __FILE__)

Gem::Specification.new 'typero', Typero::VERSION do |s|
  s.summary     = 'Ruby type system'
  s.description = 'Simple and fast ruby type system. Enforce types as Array, Email, Boolean for ruby class instances'
  s.authors     = ["Dino Reic"]
  s.email       = 'reic.dino@gmail.com'
  s.files       = Dir['./lib/**/*.rb'].reverse
  s.homepage    = 'https://github.com/dux/typero'
  s.license     = 'MIT'
  s.add_runtime_dependency 'fast_blank'
  # s.add_runtime_dependency 'active_support/core_ext/string'
end