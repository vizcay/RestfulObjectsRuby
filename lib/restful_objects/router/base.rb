require_relative 'supporting_resources'
require_relative 'domain_object_resources'
require_relative 'domain_type_resources'

module RestfulObjects
  module Router
    class Base < Sinatra::Base
      register RestfulObjects::Router::SupportingResources
      register RestfulObjects::Router::DomainObjectResources
      register RestfulObjects::Router::DomainTypeResources

      set :bind, '0.0.0.0' # listen at all networks (needed for example using vagrant port forwarding)

      after do
        headers['Access-Control-Allow-Origin'] = '*'
      end

      helpers do
        def model
          RestfulObjects::DomainModel.current
        end

        def process_params
          if request.query_string != ''
            query_params = CGI.parse(request.query_string)
            parameters = Hash.new
            query_params.each { |key, value| parameters[key] = { 'value' => value.first } }
            parameters.to_json
          else
            request.body.read
          end
        end
      end
    end
  end
end

