# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dug/version'

Gem::Specification.new do |spec|
  spec.name          = "dug"
  spec.version       = Dug::VERSION
  spec.authors       = ["Chris Arcand"]
  spec.email         = ["chris@chrisarcand.com"]

  spec.summary       = %q{[D]amn yo[u], [G]mail. A gem to organize your GitHub notification emails in ways Gmail filters can't.}
  spec.description   = %q{[D]amn yo[u], [G]mail. A gemified script to organize your GitHub notification emails using a simple configuration file in ways Gmail filters can't, such as X-GitHub-Reason headers.}
  spec.homepage      = "https://github.com/chrisarcand/dug"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "google-api-client", "~> 0.9"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "simplecov"
end
