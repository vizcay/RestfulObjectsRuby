require_relative 'object_macros'
require_relative 'object_base'
require_relative 'object_properties'
require_relative 'object_collections'
require_relative 'object_actions'

module RestfulObjects::Object
  include RestfulObjects::LinkGenerator

  def self.included(base)
    RestfulObjects::DomainModel.current.register_type(base.name)

    base.class_eval do
      extend RestfulObjects::ObjectMacros
      include RestfulObjects::ObjectBase
      include RestfulObjects::ObjectProperties
      include RestfulObjects::ObjectCollections
      include RestfulObjects::ObjectActions
    end
  end
end
