module RestfulObjects
  module Service
    include LinkGenerator

    def self.included(base)
      RestfulObjects::DomainModel.current.register_type(base.name)

      base.class_eval do
        extend ObjectMacros
        include ObjectBase
        include ObjectActions

        def rs_register_in_model
          # do_nothing
        end
      end

      RestfulObjects::DomainModel.current.register_service(base)
    end
  end
end

