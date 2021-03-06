module RestfulObjects::ObjectBase
  attr_accessor :ro_title

  HTTP_OK = 200

  def initialize
    super
    @ro_deleted    = false
    @ro_is_service = self.class.ancestors.include?(RestfulObjects::Service)
    @ro_title      = "#{self.class.name} (#{object_id})"

    ro_domain_model.register_object(self) unless @ro_is_service
    ro_domain_type.collections.each_value do |collection|
      instance_variable_set("@#{collection.id}".to_sym, Array.new)
    end
    on_after_create if respond_to?(:on_after_create)
  end

  def ro_domain_model
    RestfulObjects::DomainModel.current
  end

  def ro_domain_type
    @ro_domain_type ||= ro_domain_model.types[self.class.name]
  end

  def ro_is_service?
    @ro_is_service
  end

  def ro_instance_id
    object_id
  end

  def ro_delete
    on_before_delete if respond_to?(:on_before_delete)
    @ro_deleted = true
    on_after_delete if respond_to?(:on_after_delete)
    {}.to_json
  end

  def ro_deleted?
    @ro_deleted
  end

  def ro_get_representation_response
    [HTTP_OK, { 'Content-Type' => ro_content_type_for_object(ro_domain_type.id) }, ro_get_representation.to_json]
  end

  def encode_value(value, type, property_name = '')
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
        if value.respond_to?(:ro_property_relation_representation, true)
          value.ro_property_relation_representation(property_name)
        else
          raise "encode_value unsupported property type: #{type}"
        end
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
        if [true, 'true'].include?(value)
          true
        elsif [false, 'false'].include?(value)
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

  def ro_relative_url
    "/objects/#{self.class.name}/#{self.object_id}"
  end

  def ro_absolute_url
    "#{ro_domain_model.base_url}#{ro_relative_url}"
  end

  def get_self_link
    link_to(:self, ro_relative_url, :object)
  end

  protected

  def ro_get_representation(include_self_link = true)
    result = {
      'title' => ro_title,
      'members' => ro_generate_members,
      'links' => [ link_to(:described_by, "/domain-types/#{ro_domain_type.id}", :domain_type) ],
      'extensions' => ro_domain_type.metadata }
    if ro_is_service?
      result['serviceId'] = ro_domain_type.id
      result['links'] << link_to(:self, "/services/#{ro_domain_type.id}", :object) if include_self_link
    else
      result['instanceId'] = ro_instance_id.to_s
      result['links'] << link_to(:self, "/objects/#{ro_domain_type.id}/#{ro_instance_id}", :object) if include_self_link
    end
    result
  end

  def ro_generate_members
    if ro_is_service?
      actions_members
    else
      ro_properties_members.merge(collections_members.merge(actions_members))
    end
  end

  def ro_property_relation_representation(property_name)
    representation = link_to(:value, "/objects/#{self.class.name}/#{object_id}", :object, property: property_name)
    representation['title'] = ro_title
    representation
  end

  def ro_properties_members
    members = {}
    ro_domain_type.properties.each do |name, property|
      members[name] = {
        'memberType' => 'property',
        'value' => ro_get_property_as_json(name),
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
          if ro_get_property_metadata(name).is_reference
            choices_json = choices.map { |object| object.ro_property_relation_representation(name) }
          else
            choices_json = choices.map { |value| decode_value(value, ro_get_property_metadata(name).return_type) }
          end
          members[name]['choices'] = choices_json
        end
      end
    end
    members
  end

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

  def actions_members
    members = {}
    ro_domain_type.actions.each do |name, action|
      members[name] = {
        'memberType' => 'action',
        'links' => [
          !ro_is_service? ?
            link_to(:details, "/objects/#{self.class.name}/#{object_id}/actions/#{name}", :object_action, action: name)
            :
            link_to(:details, "/services/#{self.class.name}/actions/#{name}", :object_action, action: name)
        ],
        'extensions' => action.metadata
      }
    end
    members
  end
end
