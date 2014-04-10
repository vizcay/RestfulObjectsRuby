module RestfulObjects
  module Service
    include LinkGenerator

    def self.included(base)
      RestfulObjects::DomainModel.current.types.add(base.name)

      base.class_eval do
        extend ObjectMacros
        include ObjectBase
        include ObjectActions

        def rs_register_in_model
          # do_nothing
        end
      end

      RestfulObjects::DomainModel.current.services.register(base)
    end
  end
end
