require 'bigdecimal'
require 'base64'

module RestfulObjects
  module Object
    include LinkGenerator

    def self.included(base)
      RestfulObjects::DomainModel.current.types.add(base.name)

      base.class_eval do
        extend ObjectMacros
        include ObjectBase
        include ObjectProperties
        include ObjectCollections
        include ObjectActions
      end
    end
  end

  module ObjectBase
    attr_accessor :is_service, :title

    def initialize
      super
      @deleted = false
      @is_service = self.class.ancestors.include? RestfulObjects::Service
      @title = "#{self.class.name} (#{object_id})"
      rs_register_in_model
      rs_type.collections.each_value { |collection| instance_variable_set "@#{collection.id}".to_sym, Array.new }
      on_after_create if respond_to? :on_after_create
    end

    def rs_register_in_model
      rs_model.objects.register(self) if not @is_service
    end

    def rs_model
      RestfulObjects::DomainModel.current
    end

    def rs_type
      rs_model.types[self.class.name]
    end

    def get_representation
      HttpResponse.new(representation.to_json,
                       'application/json;profile="urn:org.restfulobjects:repr-types/object";x-ro-domain-type="' + rs_type.id + '"')
    end

    def rs_instance_id
      object_id
    end

    def representation
      representation = {
        'title' => title,
        'members' => generate_members,
        'links' => [ link_to(:described_by, "/domain-types/#{self.class.name}", :domain_type) ],
        'extensions' => rs_type.metadata
      }

      if not is_service
        representation['instanceId'] = object_id.to_s
        representation['links'] << link_to(:self, "/objects/#{self.class.name}/#{object_id}", :object)
      else
        representation['serviceId'] = self.class.name
        representation['links'] << link_to(:self, "/services/#{self.class.name}", :object)
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
      on_before_delete if respond_to? :on_before_delete
      @deleted = true
      on_after_delete if respond_to? :on_after_delete
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
