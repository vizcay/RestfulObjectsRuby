module RestfulObjects::Router::DomainTypeResources
  def self.registered(router)
    # D.21 Domain Types
    router.get "/domain-types" do
      model.get_type_list_representation
    end

    # D.22 Domain Type
    router.get "/domain-types/:domain_type" do
      model.types[params[:domain_type]].get_representation
    end

    # D.23 Domain Type Property
    router.get "/domain-types/:domain_type/properties/:property_id" do
      model.types[params[:domain_type]].properties[params[:property_id]].get_representation
    end

    # D.24 Domain Type Collection
    router.get "/domain-types/:domain_type/collections/:collection_id" do
      model.types[params[:domain_type]].collections[params[:collection_id]].get_representation
    end

    # D.25 Domain Type Action
    router.get "/domain-types/:domain_type/actions/:action_id" do
      model.types[params[:domain_type]].actions[params[:action_id]].get_representation
    end

    # D.26 Domain Type Action Parameter

    # D.27 Domain Type Action Invoke
  end
end
