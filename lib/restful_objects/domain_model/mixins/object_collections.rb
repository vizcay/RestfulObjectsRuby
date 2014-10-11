module RestfulObjects
  module ObjectCollections
    def collections_members
      members = {}
      rs_type.collections.each do |name, collection|
        members[name] = {
          'memberType' => 'collection',
          'size' => rs_type.collections.count,
          'links' => [
            link_to(:details, "/objects/#{self.class.name}/#{object_id}/collections/#{name}", :object_collection, collection: name)
          ],
          'extensions' => collection.metadata
        }
      end
      members
    end

    def get_collection_as_json(collection)
      raise "collection not exists" if not rs_model.types[self.class.name].collections.include?(collection)

      value = []
      send(collection.to_sym).each do |object|
        link = link_to(:value, "/objects/#{object.rs_type.id}/#{object.rs_instance_id}", :object, method: 'GET', collection: collection)
        link['title'] = object.title
        value << link
      end

      representation = {
        'id' => collection,
        'value' => value,
        'links' => [
            link_to(:self, "/objects/#{rs_type.id}/#{rs_instance_id}/collections/#{collection}", :object_collection),
            link_to(:up, "/objects/#{rs_type.id}/#{rs_instance_id}", :object)
          ],
        'extensions' => rs_type.collections[collection].metadata
      }

      if not rs_model.types[self.class.name].collections[collection].read_only then
        add_to_link = link_to(:add_to, "/objects/#{rs_type.id}/#{rs_instance_id}/collections/#{collection}",
                              :object_collection, method: 'PUT', collection: collection)
        add_to_link['arguments'] = { 'value' => nil }
        remove_from_link = link_to(:remove_from, "/objects/#{rs_type.id}/#{rs_instance_id}/collections/#{collection}",
                                   :object_collection, method: 'DELETE', collection: collection)
        remove_from_link['arguments'] = { 'value' => nil }
        representation['links'].concat [ add_to_link, remove_from_link ]
      else
        representation['disabledReason'] =
          rs_model.types[self.class.name].collections[collection].disabled_reason
      end

      representation.to_json
    end

    def add_to_collection(collection, json)
      raise "collection not exists" if not rs_model.types[self.class.name].collections.include?(collection)
      href_value = JSON.parse(json)['value']['href']
      match = Regexp.new(".*/objects/(?<domain-type>\\w*)/(?<object-id>\\d*)").match(href_value)
      raise "Invalid request format" if not match
      domain_type = match['domain-type']
      id = match['object-id'].to_i
      raise "Value does not exists" if not rs_model.objects.include?(id)
      raise "Domain-type does not exists" if not rs_model.types.include?(domain_type)

      send(collection.to_sym).push(rs_model.objects[id])

      get_collection_as_json(collection)
    end

    def delete_from_collection(collection, json)
      raise "collection not exists" if not rs_model.types[self.class.name].collections.include?(collection)
      href_value = JSON.parse(json)['value']['href']
      match = Regexp.new(".*/objects/(?<domain-type>\\w*)/(?<object-id>\\d*)").match(href_value)
      raise "Invalid request format" if not match
      domain_type = match['domain-type']
      id = match['object-id'].to_i
      raise "Value does not exists" if not rs_model.objects.include?(id)
      raise "Domain-type does not exists" if not rs_model.types.include?(domain_type)

      send(collection.to_sym).delete(rs_model.objects[id])

      get_collection_as_json(collection)
    end
  end
end

