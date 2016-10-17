module RestfulObjects::ObjectProperties
  HTTP_OK = 200
  HTTP_NOT_FOUND = 404

  def ro_get_property_metadata(name)
    ro_domain_type.properties[name]
  end

  def ro_get_property_response(name)
    name     = String(name)
    property = ro_domain_type.properties[name]
    return [HTTP_NOT_FOUND, { 'Warning' => "No such property #{name}" }, ''] unless property

    representation = {
      name =>
        { 'value' => ro_get_property_as_json(name),
          'links' => [
            link_to(:self, "/objects/#{ro_domain_type.id}/#{ro_instance_id}/properties/#{name}", :object_property),
            link_to(:up, "/objects/#{ro_domain_type.id}/#{ro_instance_id}", :object) ],
          'extensions' => property.metadata
        }
    }

    unless property.read_only
      representation[name]['links'] << link_to(:modify,
                                               "/objects/#{ro_domain_type.id}/#{ro_instance_id}/properties/#{name}",
                                               :object_property,
                                               { property: name, method: 'PUT', arguments: { 'value' => nil } })
      representation[name]['links'] << link_to(:clear,
                                               "/objects/#{ro_domain_type.id}/#{ro_instance_id}/properties/#{name}",
                                               :object_property,
                                               { property: name, method: 'DELETE'})
      if self.respond_to?("#{name}_choices")
        choices = self.send("#{name}_choices")
        raise "value returned by #{name}_choices method should be an Array" unless choices.is_a?(Array)
        if ro_get_property_metadata(name).is_reference
          choices_json = choices.map { |object| object.ro_property_relation_representation(name) }
        else
          choices_json = choices.map { |value| decode_value(value, ro_get_property_metadata(name).return_type) }
        end
        representation[name]['choices'] = choices_json
      end
    else
      representation[name]['disabledReason'] = property.disabled_reason
    end

    [HTTP_OK, { 'Content-Type' => ro_content_type_for_property }, representation.to_json]
  end

  def ro_put_property_and_get_response(name, input)
    name     = String(name)
    property = ro_domain_type.properties[name]
    return [HTTP_NOT_FOUND, { 'Warning' => "No such property #{name}" }, ''] unless property
    return [HTTP_FORBIDDEN, { 'Warning' => "Read-only property #{name}" }, ''] if property.read_only

    ro_set_property_as_json(name, JSON.parse(input)['value'])
    on_after_update if respond_to?(:on_after_update)

    ro_get_property_response(name)
  end

  def ro_put_multiple_properties_and_get_response(input)
    properties = JSON.parse(input)
    properties.each do |name, value|
      raise 'property not exists' unless ro_domain_type.properties.include?(name)
      raise 'read-only property' if ro_domain_type.properties[name].read_only
      ro_set_property_as_json(name, value['value'])
      on_after_update if respond_to?(:on_after_update)
    end
    [HTTP_OK, { 'Content-Type' => ro_content_type_for_object(ro_domain_type.id) }, ro_get_representation(false).to_json]
  end

  def ro_clear_property_and_get_response(name)
    name = String(name)
    if !ro_get_property_metadata(name)
      return [HTTP_NOT_FOUND, { 'Warning' => "No such property #{name}" }, '']
    elsif ro_get_property_metadata(name).read_only
      return [HTTP_FORBIDDEN, { 'Warning' => "Read-only property #{name}" }, '']
    end

    send("#{name}=", nil)

    on_after_update if respond_to?(:on_after_update)
    return ro_get_property_response(name)
  end

  protected

  def ro_get_property_as_json(name)
    encode_value(send(name), ro_get_property_metadata(name).return_type, name)
  end

  def ro_set_property_as_json(name, json)
    if ro_get_property_metadata(name).is_reference
      unless json.nil?
        href_value = json['href']
        match = Regexp.new(".*/objects/(?<domain-type>\\w*)/(?<object-id>\\d*)").match(href_value)
        raise "invalid property reference format: '#{href_value}'" if not match
        domain_type = match['domain-type']
        id = match['object-id'].to_i
        raise "value does not exists" if not ro_domain_model.objects.include?(id)
        raise "domain-type does not exists" if not ro_domain_model.types.include?(domain_type)
        send "#{name}=".to_sym, ro_domain_model.objects[id]
      else
        send "#{name}=".to_sym, nil
      end
    else
      send "#{name}=".to_sym, decode_value(json, ro_get_property_metadata(name).return_type)
    end
  end
end
