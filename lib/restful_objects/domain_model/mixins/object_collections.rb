module RestfulObjects::ObjectCollections
  def ro_get_collection_type(name)
    ro_domain_type.collections[name]
  end

  def ro_get_collection_response(name)
    raise "collection not exists" unless ro_get_collection_type(name)

    value = []
    send(name).each do |object|
      link = link_to(:value, "/objects/#{object.ro_domain_type.id}/#{object.ro_instance_id}", :object, method: 'GET', collection: name)
      link['title'] = object.ro_title
      value << link
    end

    representation = {
      'id' => name,
      'value' => value,
      'links' => [
          link_to(:self, "/objects/#{ro_domain_type.id}/#{ro_instance_id}/collections/#{name}", :object_collection),
          link_to(:up, "/objects/#{ro_domain_type.id}/#{ro_instance_id}", :object)
        ],
      'extensions' => ro_get_collection_type(name).metadata
    }

    unless ro_get_collection_type(name).read_only
      add_to_link = link_to(:add_to, "/objects/#{ro_domain_type.id}/#{ro_instance_id}/collections/#{name}",
                            :object_collection, method: 'PUT', collection: name)
      add_to_link['arguments'] = { 'value' => nil }
      remove_from_link = link_to(:remove_from, "/objects/#{ro_domain_type.id}/#{ro_instance_id}/collections/#{name}",
                                 :object_collection, method: 'DELETE', collection: name)
      remove_from_link['arguments'] = { 'value' => nil }
      representation['links'].concat [ add_to_link, remove_from_link ]
    else
      representation['disabledReason'] = ro_get_collection_type(name).disabled_reason
    end

    representation.to_json
  end

  def ro_add_to_collection_and_get_response(name, json)
    raise "collection not exists" unless ro_get_collection_type(name)
    href_value = JSON.parse(json)['value']['href']
    match = Regexp.new(".*/objects/(?<domain-type>\\w*)/(?<object-id>\\d*)").match(href_value)
    raise "Invalid request format" if not match
    domain_type = match['domain-type']
    id = match['object-id'].to_i
    raise "Value does not exists" unless ro_domain_model.objects.include?(id)
    raise "Domain-type does not exists" unless ro_domain_model.types.include?(domain_type)

    send(name).push(ro_domain_model.objects[id])

    return ro_get_collection_response(name)
  end

  def ro_delete_from_collection_and_get_response(name, json)
    raise "collection not exists" unless ro_get_collection_type(name)
    href_value = JSON.parse(json)['value']['href']
    match = Regexp.new(".*/objects/(?<domain-type>\\w*)/(?<object-id>\\d*)").match(href_value)
    raise "Invalid request format" if not match
    domain_type = match['domain-type']
    id = match['object-id'].to_i
    raise "Value does not exists" unless ro_domain_model.objects.include?(id)
    raise "Domain-type does not exists" unless ro_domain_model.types.include?(domain_type)

    send(name).delete(ro_domain_model.objects[id])

    return ro_get_collection_response(name)
  end

  protected

  def collections_members
    members = {}
    ro_domain_type.collections.each do |name, collection|
      members[name] = {
        'memberType' => 'collection',
        'size' => ro_domain_type.collections.count,
        'links' => [
          link_to(:details, "/objects/#{self.class.name}/#{object_id}/collections/#{name}", :object_collection, collection: name)
        ],
        'extensions' => collection.metadata
      }
    end
    members
  end

end
