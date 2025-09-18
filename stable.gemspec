require_relative "lib/stable/version"

Gem::Specification.new do |s|
  s.name        = "stable"
  s.version     = Stable::VERSION
  s.description = "regression testing is all you need"
  s.summary     = "an automatic unit/regression test system that captures your usage and records it for future playback"
  s.authors     = ["Jeff Lunt"]
  s.email       = "jefflunt@gmail.com"
  s.files       = Dir["lib/**/*.rb", "lib/**/*.rake"]
  s.homepage    = "https://github.com/jefflunt/stable"
  s.license     = "MIT"
  s.required_ruby_version = ">= 3.4"
  s.add_runtime_dependency "rake", "~> 13.0"
end
