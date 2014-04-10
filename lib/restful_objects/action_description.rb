module RestfulObjects
  class ActionDescription
    include LinkGenerator

    attr_reader :id, :kind_result_type, :result_type, :parameters
    attr_accessor :friendly_name, :description, :member_order, :disabled_reason

    def initialize(id, result_type, domain_type, parameters = {}, options = {})
      @id = id

      if result_type == :void
        result_type = [:void, :void]
      elsif result_type.is_a?(Symbol)
        result_type = [:scalar, result_type]
      end
      raise "result type should be a symbol or an array" if not result_type.is_a?(Array)
      raise "result type kind '#{result_type.last}' unssuported" if
        not [:void, :scalar, :object, :proto_object, :list].include?(result_type.first)
      @kind_result_type = result_type.first
      @result_type = result_type.last
      case @kind_result_type
        when :scalar
          raise "result type for scalar '#{result_type.last}' unssuported" if
            not [:string, :int, :decimal, :date, :blob].include?(@result_type)
        when :object, :proto_object, :list
          raise "result type should be a class or a string with a class name" if
            not (@result_type.is_a?(Class) || @result_type.is_a?(String))
      end

      @parameters = ParameterDescriptionList.new
      parameters.each { |name, definition| @parameters.add(name, definition) }

      @domain_type = domain_type
      @friendly_name = options[:friendly_name] || id
      @description = options[:description] || id
      @member_order = options[:member_order] || 0
      @disabled_reason = options[:disabled_reason] || ''
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
      result = { 'friendlyName' => friendly_name,
                 'description' => description,
                 'returnType' => result_type,
                 'hasParams' => has_params,
                 'memberOrder' => member_order }
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
