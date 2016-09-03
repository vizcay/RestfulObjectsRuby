module RestfulObjects::ObjectBase
  attr_accessor :title

  def initialize
    super
    @ro_deleted    = false
    @ro_is_service = self.class.ancestors.include?(RestfulObjects::Service)
    @title         = "#{self.class.name} (#{object_id})"

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
    ro_domain_model.types[self.class.name]
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
    [200,
     { 'Content-Type' =>
         "application/json;profile=\"urn:org.restfulobjects:repr-types/object\";x-ro-domain-type=\"#{ro_domain_type.id}\"" },
     ro_get_representation.to_json]
  end

  def ro_get_representation(include_self_link = true)
    result = {
      'title' => title,
      'members' => ro_generate_members,
      'links' => [ link_to(:described_by, "/domain-types/#{self.class.name}", :domain_type) ],
      'extensions' => ro_domain_type.metadata
    }
    if ro_is_service?
      result['serviceId'] = self.class.name
      result['links'] << link_to(:self, "/services/#{self.class.name}", :object) if include_self_link
    else
      result['instanceId'] = object_id.to_s
      result['links'] << link_to(:self, "/objects/#{self.class.name}/#{object_id}", :object) if include_self_link
    end
    result
  end

  def ro_put_properties_and_get_representation_response(input)
    properties = JSON.parse(input)
    properties.each do |property, container|
      raise 'property not exists' unless ro_domain_type.properties.include?(property)
      raise 'read-only property' if ro_domain_type.properties[property].read_only
      set_property_value(property, container['value'])
      on_after_update if respond_to?(:on_after_update)
    end
    [200,
     { 'Content-Type' =>
         "application/json;profile=\"urn:org.restfulobjects:repr-types/object\";x-ro-domain-type=\"#{ro_domain_type.id}\"" },
     ro_get_representation(false).to_json]
  end

  def ro_generate_members
    if ro_is_service?
      actions_members
    else
      properties_members.merge(collections_members.merge(actions_members))
    end
  end

  def get_property_rel_representation(property_name)
    representation = link_to(:value, "/objects/#{self.class.name}/#{object_id}", :object, property: property_name)
    representation['title'] = @title
    representation
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
        if value.respond_to?(:get_property_rel_representation)
          value.get_property_rel_representation(property_name)
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
end
