# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sprouter/version'

Gem::Specification.new do |spec|
  spec.name          = "sprouter"
  spec.version       = Sprouter::VERSION
  spec.authors       = ["Matt Burke"]
  spec.email         = ["spraints@gmail.com"]

  spec.summary       = %q{A couple of scripts that set up pf's tables, based on some simple rules}
  spec.description   = %q{'sprouter status' shows the pf tables. 'sprouter apply config.yaml' updates the tables based on the rules in config.yaml.}
  spec.homepage      = "https://github.com/spraints/sprouter"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(script)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
