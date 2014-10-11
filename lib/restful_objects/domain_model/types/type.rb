require_relative 'property_description'
require_relative 'collection_description'
require_relative 'action_description'

module RestfulObjects
  class Type
    include LinkGenerator

    attr_reader :id, :is_service, :properties, :collections, :actions
    attr_accessor :friendly_name, :plural_name, :description

    def initialize(id)
      @id            = id
      @properties    = {}
      @collections   = {}
      @actions       = {}
      @is_service    = false
      @friendly_name = ''
      @plural_name   = ''
      @description   = ''
    end

    def register_property(name, return_type, options = {})
      options[:member_order] ||= @properties.count + 1
      @properties[name]        = PropertyDescription.new(name, @id, return_type, options)
    end

    def register_collection(name, type, options = {})
      options[:member_order] ||= @collections.count + 1
      @collections[name]       = CollectionDescription.new(name, type, @id, options)
    end

    def register_action(name, options = {})
      options[:member_order] ||= @actions.count + 1
      @actions[name]           = ActionDescription.new(name, @id, options)
    end

    def get_representation
      { 'name' => @id,
        'domainType' => @id,
        'friendlyName' => @friendly_name,
        'pluralName' => @plural_name,
        'description' => @description,
        'isService' => @is_service,
        'members' => get_members,
        'typeActions' => get_type_actions,
        'links' => [ link_to(:self, "/domain-types/#{@id}", :domain_type) ],
        'extensions' => {}
      }.to_json
    end

    def new_proto_persistent_object
      persist_link = link_to(:persist, "/objects/#{id}", :object, method: 'POST')
      persist_link['arguments'] = { 'members' => {} }
      members = {}
      properties.each do |name, property|
        if not property.optional
          persist_link['arguments']['members'][name] = {
            'value' => nil,
            'extensions' => property.metadata }
        end
        members[name] = { 'value' => nil }
      end

      { 'title' => "New #{id}",
        'members' => members,
        'links' => [ persist_link ],
        'extensions' => {} }
    end

    def post_prototype_object(members_json)
      members = JSON.parse(members_json)['members']

      new_object = Object.const_get(@id.to_sym).new

      members.each do |name, value|
        if properties.include?(name) then
          new_object.put_property_as_json(name, value.to_json)
        else
          raise "member of property '#{name}' not found in type '#{@id}'"
        end
      end

      new_object.get_representation
    end

    def metadata
      { 'domainType' => id,
        'friendlyName' => friendly_name,
        'pluralName' => plural_name,
        'description' => description,
        'isService' => is_service }
    end

    private

      def get_members
        properties_members.merge(collections_members.merge(actions_members))
      end

      def properties_members
        result = Hash.new
        @properties.each do |name, property|
          result[name] = link_to(:property, "/domain-types/#{@id}/properties/#{name}", :property_description)
        end
        result
      end

      def collections_members
        result = Hash.new
        @collections.each do |name, collection|
          result[name] = link_to(:collection, "/domain-types/#{@id}/collections/#{name}", :collection_description)
        end
        result
      end

      def actions_members
        result = Hash.new
        @actions.each do |name, action|
          result[name] = link_to(:action, "/domain-types/#{@id}/actions/#{name}", :action_description)
        end
        result
      end

      def get_type_actions
        {}
      end
  end
end

