version = File.read File.expand_path '.version', File.dirname(__FILE__)

Gem::Specification.new 'typero', version do |s|
  s.summary     = 'Ruby type system'
  s.description = 'Simple and fast ruby type system. Enforce types as Array, Email, Boolean for ruby class instances'
  s.authors     = ["Dino Reic"]
  s.email       = 'reic.dino@gmail.com'
  s.files       = Dir['./lib/**/*.rb']+['./.version']
  s.homepage    = 'https://github.com/dux/typero'
  s.license     = 'MIT'

  s.add_runtime_dependency 'fast_blank'
end