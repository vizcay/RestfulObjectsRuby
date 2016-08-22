module RestfulObjects::ObjectMacros
  def property(name, type, options = {})
    RestfulObjects::DomainModel.current.types[self.name].register_property(name.to_s, type, options)

    define_method(name) do
      instance_variable_get("@#{name}")
    end

    unless options[:read_only]
      define_method("#{name}=") do |value|
        if options[:max_length] && value && value.length > options[:max_length]
          raise ArgumentError.new("string max length exceeded")
        end
        instance_variable_set("@#{name}", value)
      end
    end
  end

  def collection(name, type, options = {})
    type = type.name if type.is_a?(Class)

    RestfulObjects::DomainModel.current.types[self.name].register_collection(name.to_s, type, options)

    attr_reader(name)
  end

  def action(name, options = {})
    RestfulObjects::DomainModel.current.types[self.name].register_action(name.to_s, options)
  end
end
