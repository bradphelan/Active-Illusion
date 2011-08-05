# Provide a simple gemspec so you can easily use your
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name        = "active_illusion"
  s.summary     = "Turn in SQL into an active relation compatible model"
  s.description = ""
  s.files       = `git ls-files`.split "\n"
  s.authors     = ["Brad Phelan"]
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.add_dependency  'activerecord', '>= 3.1.0.rc4'  
  s.add_dependency  'squeel', '>= 0.8.5'  
end
