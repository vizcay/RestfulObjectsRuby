module RestfulObjects
  class Server < Sinatra::Base
    after do
      headers['Access-Control-Allow-Origin'] = '*'
    end

    # B. SUPPORTING RESOURCES
    # B.5 Homepage
    get '/' do
      model.get_homepage
    end
    # B.6 User
    get "/user" do
      model.get_user_as_json
    end
    # B.7 Services
    get "/services" do
      model.get_services
    end
    # B.8 Version
    get '/version' do
      model.get_version
    end
    # B.9 Objects of Type Resource
    post '/objects/:domain_type' do
      populate_response model.types[params[:domain_type]].post_prototype_object(request.body.read)
    end
    # C. DOMAIN OBJECT RESOURCES
    # C.14 Domain Object
    get "/objects/:domain_type/:instance_id" do
      populate_response model.objects[params[:instance_id].to_i].get_representation
    end
    delete "/objects/:domain_type/:instance_id" do
      model.objects[params[:instance_id].to_i].rs_delete
    end
    # C.15 Domain Services
    get "/services/:service_id" do
      populate_response model.services[params[:service_id]].get_representation
    end
    # C.16 Property
    get "/objects/:domain_type/:instance_id/properties/:property_id" do
      model.objects[params[:instance_id].to_i].get_property_as_json(params[:property_id])
    end
    put "/objects/:domain_type/:instance_id/properties/:property_id" do
      model.objects[params[:instance_id].to_i].put_property_as_json(params[:property_id], request.body.read)
    end
    delete "/objects/:domain_type/:instance_id/properties/:property_id" do
      model.objects[params[:instance_id].to_i].clear_property(params[:property_id])
    end
    # C.17 Collection #
    get "/objects/:domain_type/:instance_id/collections/:collection_id" do
      model.objects[params[:instance_id].to_i].get_collection_as_json(params[:collection_id])
    end
    put "/objects/:domain_type/:instance_id/collections/:collection_id" do
      model.objects[params[:instance_id].to_i].add_to_collection(params[:collection_id], request.body.read)
    end
    delete "/objects/:domain_type/:instance_id/collections/:collection_id" do
      model.objects[params[:instance_id].to_i].delete_from_collection(params[:collection_id], request.body.read)
    end
    # C.18 Action
    get "/objects/:domain_type/:instance_id/actions/:action_id" do
      model.objects[params[:instance_id].to_i].get_action(params[:action_id])
    end
    get "/services/:service_id/actions/:action_id" do
      model.services[params[:service_id]].get_action(params[:action_id])
    end
    # C.19 Action Invoke
    get "/objects/:domain_type/:instance_id/actions/:action_id/invoke" do
      model.objects[params[:instance_id].to_i].get_action_invoke(params[:action_id], process_params)
    end
    get "/services/:service_id/actions/:action_id/invoke" do
      model.services[params[:service_id]].get_action_invoke(params[:action_id], process_params)
    end
    post "/objects/:domain_type/:instance_id/actions/:action_id/invoke" do
      model.objects[params[:instance_id].to_i].get_action_invoke(params[:action_id], request.body.read)
    end
    post "/services/:service_id/actions/:action_id/invoke" do
      model.services[params[:service_id]].get_action_invoke(params[:action_id], request.body.read)
    end
    # D. DOMAIN TYPE RESOURCES #
    # D.21 Domain Types
    get "/domain-types" do
      model.types.get_representation
    end
    # D.22 Domain Type
    get "/domain-types/:domain_type" do
      model.types[params[:domain_type]].get_representation
    end
    # D.23 Domain Type Property
    get "/domain-types/:domain_type/properties/:property_id" do
      model.types[params[:domain_type]].properties[params[:property_id]].get_representation
    end
    # D.24 Domain Type Collection
    get "/domain-types/:domain_type/collections/:collection_id" do
      model.types[params[:domain_type]].collections[params[:collection_id]].get_representation
    end
    # D.25 Domain Type Action
    get "/domain-types/:domain_type/actions/:action_id" do
      model.types[params[:domain_type]].actions[params[:action_id]].get_representation
    end
    # D.26 Domain Type Action Parameter

    # D.27 Domain Type Action Invoke

    # ------------------------------------------------------------------------------------------ #
    helpers do
      def model
        RestfulObjects::DomainModel.current
      end

      def populate_response(http_response)
        content_type http_response.content_type
        status http_response.status
        body http_response.body
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
