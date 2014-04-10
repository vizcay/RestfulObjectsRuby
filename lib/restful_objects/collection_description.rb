module RestfulObjects
  class CollectionDescription
    include LinkGenerator
    attr_reader :id, :type, :read_only
    attr_accessor :friendly_name, :description, :plural_form, :member_order, :disabled_reason

    def initialize(id, type, domain_type, options = {})
      @id = id
      @type = type
      @domain_type = domain_type
      @read_only = options[:read_only].nil? ? false : options[:read_only]
      @disabled_reason = options[:disabled_reason] || 'read only collection' if read_only
      @friendly_name = options[:friendly_name] || id
      @description = options[:description] || id
      @plural_form = options[:plural_form]
      @member_order = options[:member_order]
    end

    def get_representation
      representation = {
        'id' => id,
        'memberOrder' => member_order,
        'links' => [
          link_to(:self, "/domain-types/#{@domain_type}/collections/#{@id}", :collection_description),
          link_to(:up, "/domain-types/#{@domain_type}", :domain_type),
          link_to(:return_type, "/domain-types/list", :domain_type),
          link_to(:element_type, "/domain-types/#{@type}", :domain_type)
        ],
        'extensions' => metadata
      }

      representation['friendlyName'] = friendly_name if friendly_name
      representation['description'] = description if description

      representation.to_json
    end

    def metadata
      { 'friendlyName' => friendly_name,
        'description' => description,
        'returnType' => 'list',
        'elementType' => type,
        'memberOrder' => member_order,
        'pluralForm' => plural_form }
    end
  end
end
