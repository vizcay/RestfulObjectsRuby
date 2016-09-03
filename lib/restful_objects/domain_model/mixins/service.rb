module RestfulObjects::Service
  include RestfulObjects::LinkGenerator

  def self.included(base)
    RestfulObjects::DomainModel.current.register_type(base.name)
    RestfulObjects::DomainModel.current.register_service(base)

    base.class_eval do
      extend RestfulObjects::ObjectMacros
      include RestfulObjects::ObjectBase
      include RestfulObjects::ObjectActions
    end
  end
end
