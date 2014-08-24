# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'restful_objects/version'

Gem::Specification.new do |spec|
  spec.name          = "restful_objects"
  spec.version       = RestfulObjects::VERSION
  spec.authors       = ["Pablo Vizcay"]
  spec.email         = ["pabo.vizcay@gmail.com"]
  spec.description   = %q{This gem is a framework for implementing Restful Objects servers.}
  spec.summary       = %q{This gem is a framework for implementing Restful Objects servers.}
  spec.homepage      = "https://github.com/vizcay/RestfulObjectsRuby"
  spec.license       = "MIT"

  spec.files         = Dir.glob("{bin,lib,spec}/**/*") + %w(LICENSE README.md)

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler",          "~> 1.3"
  spec.add_development_dependency "rake",             "10.1.1"
  spec.add_development_dependency "rspec",            "2.14.1"
  spec.add_development_dependency "rack-test",        "0.6.2"
  spec.add_development_dependency "json_expressions", "0.8.2"

  spec.add_runtime_dependency "sinatra", "1.4.4"
end

