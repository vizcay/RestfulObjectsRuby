module RestfulObjects
  module ObjectMacros
    def property(name, type, options = {})
      RestfulObjects::DomainModel.current.types[self.name].properties.add(name.to_s, type, options)
      if options[:read_only]
        self.class_eval { attr_reader name }
      else
        if not options[:max_length]
          self.class_eval { attr_accessor name }
        else
          self.class_eval do
            attr_reader name

            define_method "#{name}=".to_sym do |value|
              raise "string max length exceeded" if value && value.length > options[:max_length]
              instance_variable_set("@#{name}".to_sym, value)
            end
          end
        end
      end
    end

    def collection(name, type, options = {})
      type = type.name if type.is_a? Class

      RestfulObjects::DomainModel.current.types[self.name].collections.add(name.to_s, type, options)

      self.class_eval { attr_reader name }
    end

    def action(name, options = {})
      RestfulObjects::DomainModel.current.types[self.name].actions.add(name.to_s, options)
    end
  end
end
