$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'postmaster/version'

spec = Gem::Specification.new do |s|
  s.name = 'postmaster'
  s.version = Postmaster::VERSION
  s.summary = 'Library for postmaster.io service'
  s.description = 'Postmaster takes the pain out of sending shipments via UPS, Fedex, and USPS. Save money before you ship, while you ship, and after you ship. See https://postmaster.io for details.'
  s.authors = ['Postmaster']
  s.email = ['support@postmaster.io']
  s.homepage = 'https://postmaster.io'
  s.require_paths = %w{lib}

  s.add_dependency('rest-client', '~> 1.4')
  s.add_dependency('multi_json', '>= 1.0.4', '< 2')

  s.add_development_dependency('mocha')
  s.add_development_dependency('shoulda')
  s.add_development_dependency('test-unit')
  s.add_development_dependency('rake')

  s.files = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.require_paths = ['lib']
end
