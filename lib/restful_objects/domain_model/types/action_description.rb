require_relative 'parameter_description_list'

module RestfulObjects
  class ActionDescription
    include LinkGenerator

    attr_reader :id, :kind_result_type, :result_type, :parameters
    attr_accessor :friendly_name, :description, :member_order, :disabled_reason

    def initialize(id, domain_type, options)
      @id              = id
      @domain_type     = domain_type
      @friendly_name   = options[:friendly_name]   || id
      @description     = options[:description]     || id
      @member_order    = options[:member_order]    || 0
      @disabled_reason = options[:disabled_reason] || ''

      case options[:return_type]
        when NilClass
          @result_type      = :void
          @kind_result_type = :void
        when Symbol
          if options[:return_type] == :void
            @result_type      = :void
            @kind_result_type = :void
          else
            raise "result type for scalar '#{options[:return_type]}' unssuported" unless [:string, :int, :bool, :decimal, :date, :blob].include?(options[:return_type])
            @result_type      = options[:return_type]
            @kind_result_type = :scalar
          end
        when Hash
          options[:return_type]
          if options[:return_type][:object]
            @result_type      = options[:return_type][:object]
            @kind_result_type = :object
          elsif options[:return_type][:proto_object]
            @result_type      = options[:return_type][:proto_object]
            @kind_result_type = :proto_object
          elsif options[:return_type][:list]
            @result_type      = options[:return_type][:list]
            @kind_result_type = :list
          else
            raise 'invalid return_type: object, proto_object or list key expected'
          end
          unless @result_type.is_a?(Class) or @result_type.is_a?(String)
            raise 'return_type object, proto_object or list value should be a class or a string'
          end
        else
          raise 'invalid return_type: symbol or hash expected'
      end

      @parameters = ParameterDescriptionList.new
      options[:parameters].each { |name, definition| @parameters.add(name, definition) } if options[:parameters]
    end

    def get_representation
      representation = {
        'id' => @id,
        'hasParams' => has_params,
        'memberOrder' => @member_order,
        'parameters' => parameters_list,
        'links' => [
          link_to(:self, "/domain-types/#{@domain_type}/actions/#{@id}", :action_description),
          link_to(:up, "/domain-types/#{@domain_type}", :domain_type),
          link_to(:return_type, "/domain-types/#{result_type}", :domain_type)
        ],
        'extensions' => {}
      }

      representation['friendlyName'] = friendly_name if friendly_name
      representation['description'] = description if description

      representation.to_json
    end

    def metadata
      {
        'friendlyName' => friendly_name,
        'description'  => description,
        'returnType'   => result_type,
        'hasParams'    => has_params,
        'memberOrder'  => member_order
      }
    end

    def has_params
      not @parameters.empty?
    end

    def parameters_list
      result = {}
      parameters.each do |name, parameter|
        result[name] = {
          'extension' => parameter.metadata
        }
      end
      result
    end
  end
end
