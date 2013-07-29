# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cronmon/version'

Gem::Specification.new do |spec|
  spec.name          = "cronmon"
  spec.version       = Cronmon::VERSION
  spec.authors       = ["Jason Adam Young"]
  spec.email         = ["jayoung@extension.org"]
  spec.description   = %q{Cronmon is a gem for internal cron management}
  spec.summary       = %q{Cronmon is a gem for internal cron management}
  spec.homepage      = ""
  spec.license       = "BSD"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency('thor', '>= 0.16.0')
  spec.add_dependency('oauth2')
  spec.add_dependency('facter')
  spec.add_dependency('toml-rb')
  spec.add_dependency('highline')
  spec.add_development_dependency('pry')

end
