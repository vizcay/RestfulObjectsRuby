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

  spec.files         = ["lib/restful_objects/action_description.rb",
                        "lib/restful_objects/action_list.rb",
                        "lib/restful_objects/collection_description.rb",
                        "lib/restful_objects/collection_list.rb",
                        "lib/restful_objects/http_response.rb",
                        "lib/restful_objects/link_generator.rb",
                        "lib/restful_objects/model.rb",
                        "lib/restful_objects/object.rb",
                        "lib/restful_objects/object_actions.rb",
                        "lib/restful_objects/object_collections.rb",
                        "lib/restful_objects/object_list.rb",
                        "lib/restful_objects/object_macros.rb",
                        "lib/restful_objects/object_properties.rb",
                        "lib/restful_objects/parameter_description.rb",
                        "lib/restful_objects/parameter_description_list.rb",
                        "lib/restful_objects/property_list.rb",
                        "lib/restful_objects/server.rb",
                        "lib/restful_objects/service_list.rb",
                        "lib/restful_objects/type.rb",
                        "lib/restful_objects/type_list.rb",
                        "lib/restful_objects/user.rb",
                        "lib/restful_objects/version.rb"]

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

