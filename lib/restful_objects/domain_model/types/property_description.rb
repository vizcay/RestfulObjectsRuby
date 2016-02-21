module RestfulObjects
  class PropertyDescription
    include LinkGenerator

    attr_accessor :id, :domain_type, :return_type, :is_reference, :friendly_name, :description, :optional, :read_only,
                  :member_order, :max_length, :disabled_reason, :pattern

    def initialize(id, domain_type, return_type, options)
      if return_type.is_a?(Hash)
        raise "hash with :object key expected for property reference" unless return_type.has_key?(:object)
      else
        raise "property type #{return_type} usupported" if not [:string, :int, :bool, :decimal, :date, :blob].include?(return_type)
      end

      @id              = id
      @domain_type     = domain_type
      if return_type.is_a?(Hash)
        @return_type  = return_type[:object]
        @is_reference = true
      else
        @return_type  = return_type
        @is_reference = false
      end
      @friendly_name   = options[:friendly_name] || id
      @description     = options[:description] || id
      @optional        = options[:optional].nil? ? true : options[:optional]
      @read_only       = options[:read_only].nil? ? false : options[:read_only]
      @member_order    = options[:member_order] || 1
      @max_length      = options[:max_length]
      @disabled_reason = options[:disabled_reason] || 'read-only property' if read_only
      @pattern         = options[:pattern]
    end

    def get_representation
      {
        'id'           => @id,
        'friendlyName' => friendly_name || '',
        'description'  => description || '',
        'optional'     => optional,
        'memberOrder'  => @member_order,
        'links'        => [
          link_to(:self, "/domain-types/#{@domain_type}/properties/#{@id}", :property_description),
          link_to(:up, "/domain-types/#{@domain_type}", :domain_type),
          link_to(:return_type, "/domain-types/#{@return_type}", :domain_type)
        ],
        'extensions' => {}
      }.to_json
    end

    def metadata
      result = { 'friendlyName' => friendly_name,
                 'description' => description,
                 'returnType' => return_type,
                 'format' => format,
                 'optional' => optional,
                 'memberOrder' => member_order }
      result['maxLength'] = max_length if max_length
      result['pattern'] = pattern if pattern
      result
    end

    def format
      case return_type
        when :string
          'string'
      end
    end

    def get_value_as_json
      { 'id' =>
        { 'value' => '' }
      }.to_json
    end
  end
end
