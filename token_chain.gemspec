# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'token_chain/version'

Gem::Specification.new do |spec|
  spec.name          = "token_chain"
  spec.version       = TokenChain::VERSION
  spec.authors       = ["Joel Helbling"]
  spec.email         = ["joel@joelhelbling.com"]
  spec.summary       = %q{Generates a deterministic chain of tokens from a passphrase.}
  spec.description   = %q{Generates a deterministic chain of tokens from a passphrase.}
  spec.homepage      = "http://github.com/joelhelbling/token_chain"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-given"
end
