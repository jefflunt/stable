Gem::Specification.new do |s|
  s.name        = "stable"
  s.version     = "1.8.0"
  s.description = "an automatic unit test system that captures your usage and records it for future playback"
  s.summary     = "an automatic unit test system that captures your usage and records it for future playback"
  s.authors     = ["Jeff Lunt"]
  s.email       = "jefflunt@gmail.com"
  s.files       = Dir["lib/**/*.rb"]
  s.homepage    = "https://github.com/jefflunt/stable"
  s.license     = "MIT"
  s.required_ruby_version = ">= 3.4"
  s.add_runtime_dependency "rake"
end
