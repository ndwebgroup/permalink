require "./lib/permalink/version"

Gem::Specification.new do |s|
  s.name        = "permalink"
  s.version     = Permalink::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nando Vieira", "Jonathan Arp"]
  s.email       = ["fnando.vieira@gmail.com", "webgroup@nd.edu"]
  s.homepage    = "https://github.com/ndwebgroup/permalink"
  s.summary     = "Generate permalink attributes on ActiveModel/ActiveRecord"
  s.description = s.summary
  s.license     = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map {|f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "activerecord"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "minitest-utils"
  s.add_development_dependency "rake"
end
