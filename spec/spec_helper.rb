require 'json_expressions/rspec'
require 'rack/test'
require 'pp'

require_relative '../lib/restful_objects.rb'

module Helpers
  def app
    RestfulObjects::Router::Base
  end

  def model
    RestfulObjects::DomainModel.current
  end

  def pretty_print_json(json_string)
    puts JSON.pretty_generate(JSON.parse(json_string))
  end
end

module JsonExpressions
  module RSpec
    module Matchers
      class MatchJsonExpression
        def failure_message_for_should
          "expected:\n#{JSON.pretty_generate @target}\n to match JSON expression:\n#{@expected.inspect}\n\n" + 
            @expected.last_error
        end

        def failure_message_for_should_not
          "expected:\n#{JSON.pretty_generate @target}\n not to match JSON expression:\n#{@expected.inspect}\n"
        end

        def description
          "should equal JSON expression:\n#{@expected.inspect}\n"
        end
      end
    end
  end
end


RSpec::configure do |config|
  config.include(Helpers)
  config.include Rack::Test::Methods
end

JsonExpressions::Matcher.assume_strict_arrays = false
JsonExpressions::Matcher.assume_strict_hashes = false

RestfulObjects::Router::Base.set :show_exceptions, false
RestfulObjects::Router::Base.set :raise_errors,    true

