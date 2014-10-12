module RestfulObjects
  module ObjectProperties
    def properties_members
      members = {}
      rs_type.properties.each do |name, property|
        members[name] = {
          'memberType' => 'property',
          'value' => get_property_value(name),
          'links' => [
            link_to(:details, "/objects/#{self.class.name}/#{object_id}/properties/#{name}", :object_property, property: name)
          ],
          'extensions' => property.metadata
        }

        members[name]['disabledReason'] = property.disabled_reason if property.read_only
      end
      members
    end

    def get_property_as_json(property)
      raise "Property not exists" if not rs_model.types[self.class.name].properties.include?(property)

      representation = {
        property =>
          { 'value' => get_property_value(property),
            'links' => [
              link_to(:self, "/objects/#{self.class.name}/#{object_id}/properties/#{property}", :object_property),
              link_to(:up, "/objects/#{self.class.name}/#{object_id}", :object) ],
            'extensions' => rs_model.types[self.class.name].properties[property].metadata
          }
      }

      if not rs_model.types[self.class.name].properties[property].read_only then
        representation[property]['links'].concat [
          link_to(:modify, "/objects/#{self.class.name}/#{object_id}/properties/#{property}", :object_property,
            { property: property, method: 'PUT', arguments: { 'value' => nil } }),
          link_to(:clear, "/objects/#{self.class.name}/#{object_id}/properties/#{property}", :object_property,
            { property: property, method: 'DELETE'} ) ]
      else
        representation[property]['disabledReason'] =
          rs_model.types[self.class.name].properties[property].disabled_reason
      end

      representation.to_json
    end

    def put_property_as_json(property, json)
      raise 'property not exists' unless rs_model.types[self.class.name].properties.include?(property)
      raise 'read-only property' if rs_model.types[self.class.name].properties[property].read_only

      value = JSON.parse(json)['value']
      set_property_value(property, value)
      on_after_update if respond_to? :on_after_update
      get_property_as_json(property)
    end

    def clear_property(property)
      raise "property not exists" if not rs_model.types[self.class.name].properties.include?(property)
      raise "read-only property" if rs_model.types[self.class.name].properties[property].read_only

      send("#{property}=".to_sym, nil)
      on_after_update if respond_to? :on_after_update
      get_property_as_json(property)
    end

    def property_type(property)
      rs_model.types[self.class.name].properties[property].return_type
    end

    def get_property_value(property)
      encode_value(send(property.to_sym), property_type(property))
    end

    def set_property_value(property, value)
      send("#{property}=".to_sym, decode_value(value, property_type(property)))
    end
  end
end

