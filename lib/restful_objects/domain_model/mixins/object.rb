require_relative 'object_macros'
require_relative 'object_base'
require_relative 'object_properties'
require_relative 'object_collections'
require_relative 'object_actions'

module RestfulObjects
  module Object
    include LinkGenerator

    def self.included(base)
      RestfulObjects::DomainModel.current.add_type(base.name)

      base.class_eval do
        extend ObjectMacros
        include ObjectBase
        include ObjectProperties
        include ObjectCollections
        include ObjectActions
      end
    end
  end
end

