$LOAD_PATH.unshift 'lib'
require "cipr/version"

Gem::Specification.new do |s|
  s.name              = "cipr"
  s.version           = Cipr::VERSION
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "cipr tests your pull requests."
  s.homepage          = "http://github.com/marksim/cipr"
  s.email             = "mark@quarternotecoda.com"
  s.authors           = [ "Mark Simoneau" ]
  s.has_rdoc          = false

  s.files             = %w( README.md LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("bin/**/*")
  s.files            += Dir.glob("spec/**/*")

  s.executables       = %w( cipr )

  s.add_runtime_dependency     'choice'
  s.add_runtime_dependency     'httparty'
  s.add_runtime_dependency     'git'
  s.add_development_dependency 'rspec'

  s.description       = "cipr tests your pull requests and comments the results"
end