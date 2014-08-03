# encoding: utf-8

module RestfulObjects
  module Object
    include LinkGenerator

    def self.included(base)
      RestfulObjects::DomainModel.current.types.add(base.name)

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

