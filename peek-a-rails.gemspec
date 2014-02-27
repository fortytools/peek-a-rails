$:.push File.expand_path("../lib", __FILE__)

require "peekarails/version"

Gem::Specification.new do |s|
  s.name        = "peek-a-rails"
  s.version     = Peekarails::VERSION
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.authors     = "Timo B. Kranz"
  s.email       = "tbk@42ls.de"
  s.homepage    = "https://github.com/fortytools/peek-a-rails"
  s.summary     = "Rails monitoring watch observer"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]

  s.add_dependency "haml-rails", "~> 0.4"
  s.add_dependency "redis-namespace", "~> 1.3"
  s.add_dependency "bootstrap-sass", "~> 3.1"
  s.add_dependency "rickshaw_rails", "~> 1.4.5"
  s.add_dependency "jquery-ui-rails", "~> 4.2"
end
