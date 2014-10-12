module RestfulObjects
  module ObjectBase
    attr_accessor :is_service, :title

    def initialize
      super
      @deleted    = false
      @is_service = self.class.ancestors.include? RestfulObjects::Service
      @title      = "#{self.class.name} (#{object_id})"
      rs_register_in_model
      rs_type.collections.each_value { |collection| instance_variable_set "@#{collection.id}".to_sym, Array.new }
      on_after_create if respond_to?(:on_after_create)
    end

    def rs_register_in_model
      rs_model.register_object(self) unless @is_service
    end

    def rs_model
      RestfulObjects::DomainModel.current
    end

    def rs_type
      rs_model.types[self.class.name]
    end

    def get_representation
      [200,
       { 'Content-Type' =>
           "application/json;profile=\"urn:org.restfulobjects:repr-types/object\";x-ro-domain-type=\"#{rs_type.id}\"" },
       representation.to_json]
    end

    def put_properties_and_get_representation(json)
      properties = JSON.parse(json)
      properties.each do |property, container|
        raise 'property not exists' unless rs_model.types[self.class.name].properties.include?(property)
        raise 'read-only property' if rs_model.types[self.class.name].properties[property].read_only
        set_property_value(property, container['value'])
        on_after_update if respond_to?(:on_after_update)
      end
      [200,
       { 'Content-Type' =>
           "application/json;profile=\"urn:org.restfulobjects:repr-types/object\";x-ro-domain-type=\"#{rs_type.id}\"" },
       representation(false).to_json]
    end

    def rs_instance_id
      object_id
    end

    def representation(include_self_link = true)
      representation = {
        'title' => title,
        'members' => generate_members,
        'links' => [ link_to(:described_by, "/domain-types/#{self.class.name}", :domain_type) ],
        'extensions' => rs_type.metadata
      }

      if not is_service
        representation['instanceId'] = object_id.to_s
        representation['links'] << link_to(:self, "/objects/#{self.class.name}/#{object_id}", :object) if include_self_link
      else
        representation['serviceId'] = self.class.name
        representation['links'] << link_to(:self, "/services/#{self.class.name}", :object) if include_self_link
      end

      representation
    end

    def generate_members
      if is_service
        actions_members
      else
        properties_members.merge(collections_members.merge(actions_members))
      end
    end

    def rs_delete
      on_before_delete if respond_to?(:on_before_delete)
      @deleted = true
      on_after_delete if respond_to?(:on_after_delete)
    end

    def deleted?
      @deleted
    end

    def encode_value(value, type)
      return nil if value.nil?
      case type
        when :string
          value.to_s
        when :int
          value.to_i
        when :bool
          value.to_s
        when :decimal
          value.to_f
        when :date
          value.strftime('%Y-%m-%d')
        when :blob
          Base64.encode64(value).strip
        else
          raise "encode_value unsupported property type: #{type}"
      end
    end

    def decode_value(value, type)
      return nil if value.nil?
      case type
        when :string
          value.to_s
        when :int
          value.to_i
        when :bool
          if value == 'true'
            true
          elsif value == 'false'
            false
          else
            raise ArgumentError.new "invalid boolean value: #{value}"
          end
        when :decimal
          Float(value)
        when :date
          Date.parse(value)
        when :blob
          Base64.decode64(value)
        else
          raise "decode_value unsupported property type: #{type}"
      end
    end

    def get_self_link
      link_to(:self, "/objects/#{self.class.name}/#{self.object_id}", :object)
    end
  end
end

