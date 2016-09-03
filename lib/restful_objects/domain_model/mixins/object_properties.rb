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

        if property.read_only
          members[name]['disabledReason'] = property.disabled_reason
        else
          if self.respond_to?("#{name}_choices")
            choices = self.send("#{name}_choices")
            raise "value returned by #{name}_choices method should be an Array" unless choices.is_a?(Array)
            if property_description(name).is_reference
              choices_json = choices.map { |object| object.get_property_rel_representation(name) }
            else
              choices_json = choices.map { |value| decode_value(value, property_type(name)) }
            end
            members[name]['choices'] = choices_json
          end
        end
      end
      members
    end

    def get_property_as_json(property)
      property = property.to_s if property.is_a?(Symbol)
      raise "Property not exists" if not ro_domain_model.types[self.class.name].properties.include?(property)

      representation = {
        property =>
          { 'value' => get_property_value(property),
            'links' => [
              link_to(:self, "/objects/#{self.class.name}/#{object_id}/properties/#{property}", :object_property),
              link_to(:up, "/objects/#{self.class.name}/#{object_id}", :object) ],
            'extensions' => ro_domain_model.types[self.class.name].properties[property].metadata
          }
      }

      if not ro_domain_model.types[self.class.name].properties[property].read_only then
        representation[property]['links'].concat [
          link_to(:modify, "/objects/#{self.class.name}/#{object_id}/properties/#{property}", :object_property,
            { property: property, method: 'PUT', arguments: { 'value' => nil } }),
          link_to(:clear, "/objects/#{self.class.name}/#{object_id}/properties/#{property}", :object_property,
            { property: property, method: 'DELETE'} ) ]

        if self.respond_to?("#{property}_choices")
          choices = self.send("#{property}_choices")
          raise "value returned by #{property}_choices method should be an Array" unless choices.is_a?(Array)
          if property_description(property).is_reference
            choices_json = choices.map { |object| object.get_property_rel_representation(property) }
          else
            choices_json = choices.map { |value| decode_value(value, property_type(property)) }
          end
          representation[property]['choices'] = choices_json
        end
      else
        representation[property]['disabledReason'] =
          ro_domain_model.types[self.class.name].properties[property].disabled_reason
      end

      representation.to_json
    end

    def put_property_as_json(property, json)
      property = property.to_s if property.is_a?(Symbol)
      raise 'property not exists' unless ro_domain_model.types[self.class.name].properties.include?(property)
      raise 'read-only property' if ro_domain_model.types[self.class.name].properties[property].read_only

      value = JSON.parse(json)['value']
      set_property_value(property, value)
      on_after_update if respond_to?(:on_after_update)
      get_property_as_json(property)
    end

    def clear_property(property)
      raise "property not exists" if not ro_domain_model.types[self.class.name].properties.include?(property)
      raise "read-only property" if ro_domain_model.types[self.class.name].properties[property].read_only

      send("#{property}=".to_sym, nil)
      on_after_update if respond_to?(:on_after_update)
      get_property_as_json(property)
    end

    def property_description(property)
      ro_domain_model.types[self.class.name].properties[property]
    end

    def property_type(property)
      ro_domain_model.types[self.class.name].properties[property].return_type
    end

    def get_property_value(property)
      encode_value(send(property.to_sym), property_type(property), property)
    end

    def set_property_value(property, value)
      if property_description(property).is_reference
        unless value.nil?
          href_value = value['href']
          match = Regexp.new(".*/objects/(?<domain-type>\\w*)/(?<object-id>\\d*)").match(href_value)
          raise "invalid property reference format: '#{href_value}'" if not match
          domain_type = match['domain-type']
          id = match['object-id'].to_i
          raise "value does not exists" if not ro_domain_model.objects.include?(id)
          raise "domain-type does not exists" if not ro_domain_model.types.include?(domain_type)
          send "#{property}=".to_sym, ro_domain_model.objects[id]
        else
          send "#{property}=".to_sym, nil
        end
      else
        send "#{property}=".to_sym, decode_value(value, property_type(property))
      end
    end
  end
end

