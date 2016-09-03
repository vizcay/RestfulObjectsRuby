module RestfulObjects
  module Router
    module DomainObjectResources
      def self.registered(router)
        # ** 14 Domain Object Resource & Representation **
        # 14.1
        router.get '/objects/:domain_type/:instance_id' do
          objects[params[:instance_id].to_i].get_representation
        end

        # 14.2
        router.put '/objects/:domain_type/:instance_id' do
          objects[params[:instance_id].to_i].put_properties_and_get_representation(request.body.read)
        end

        # 14.3
        router.delete '/objects/:domain_type/:instance_id' do
          objects[params[:instance_id].to_i].ro_delete
        end

        # patch to allow cross-origin put & delete requests #
        router.options "/objects/:domain_type/:instance_id" do
          headers['Access-Control-Allow-Methods'] = 'GET, DELETE, PUT, OPTIONS'
          headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Methods'
        end

        # C.15 Domain Services
        router.get "/services/:service_id" do
          model.services[params[:service_id]].get_representation
        end

        # C.16 Property
        router.get "/objects/:domain_type/:instance_id/properties/:property_id" do
          objects[params[:instance_id].to_i].get_property_as_json(params[:property_id])
        end

        router.put "/objects/:domain_type/:instance_id/properties/:property_id" do
          objects[params[:instance_id].to_i].put_property_as_json(params[:property_id], request.body.read)
        end

        router.delete "/objects/:domain_type/:instance_id/properties/:property_id" do
          objects[params[:instance_id].to_i].clear_property(params[:property_id])
        end

        # C.17 Collection #
        router.get "/objects/:domain_type/:instance_id/collections/:collection_id" do
          objects[params[:instance_id].to_i].get_collection_as_json(params[:collection_id])
        end

        router.post "/objects/:domain_type/:instance_id/collections/:collection_id" do
          objects[params[:instance_id].to_i].add_to_collection(params[:collection_id], request.body.read)
        end

        router.put "/objects/:domain_type/:instance_id/collections/:collection_id" do
          objects[params[:instance_id].to_i].add_to_collection(params[:collection_id], request.body.read)
        end

        router.delete "/objects/:domain_type/:instance_id/collections/:collection_id" do
          objects[params[:instance_id].to_i].delete_from_collection(params[:collection_id], request.body.read)
        end

        # patch to allow cross-origin put & delete requests #
        router.options "/objects/:domain_type/:instance_id/collections/:collection_id" do
          headers['Access-Control-Allow-Methods'] = 'GET, DELETE, PUT, OPTIONS'
          headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Methods'
        end

        # C.18 Action
        router.get "/objects/:domain_type/:instance_id/actions/:action_id" do
          objects[params[:instance_id].to_i].get_action(params[:action_id])
        end

        router.get "/services/:service_id/actions/:action_id" do
          model.services[params[:service_id]].get_action(params[:action_id])
        end

        # C.19 Action Invoke
        router.get "/objects/:domain_type/:instance_id/actions/:action_id/invoke" do
          objects[params[:instance_id].to_i].get_action_invoke(params[:action_id], process_params)
        end

        router.get "/services/:service_id/actions/:action_id/invoke" do
          model.services[params[:service_id]].get_action_invoke(params[:action_id], process_params)
        end

        router.post "/objects/:domain_type/:instance_id/actions/:action_id/invoke" do
          objects[params[:instance_id].to_i].get_action_invoke(params[:action_id], request.body.read)
        end

        router.post "/services/:service_id/actions/:action_id/invoke" do
          model.services[params[:service_id]].get_action_invoke(params[:action_id], request.body.read)
        end
      end
    end
  end
end

