module RestfulObjects
  class ParameterDescription
    include LinkGenerator

    attr_reader :id, :name, :number, :kind_type, :type
    attr_accessor :friendly_name, :description, :optional, :max_length, :pattern, :format

    def initialize(id, definition, number)
      @id = id
      @name = id

      if definition.is_a? Array # [type, options]
        if [:string, :int, :decimal, :date, :blob].include?(definition.first) # scalar
          @kind_type = :scalar
          @type = definition.first
        elsif definition.first.is_a?(Class) # object type
          @kind_type = :object
          @type = definition.first.name
        elsif definition.first.is_a?(Strign) # object type
          @kind_type = :object
          @type = definition.first
        else
          raise "unssuported parameter definition type #{definition.class}"
        end
        options = definition.last
      elsif definition.is_a? Symbol # scalar type
        @kind_type = :scalar
        @type = definition
        raise "result type for scalar '#{@type}' unssuported" if not [:string, :int, :decimal, :date, :blob].include?(@type)
      elsif definition.is_a? String # object type
        @kind_type = :object
        @type = definition
      elsif definition.is_a? Class # object type
        @kind_type = :object
        @type = definition.to_s
      else
        raise "unssuported parameter definition type #{definition.class}"
      end

      options ||= {}
      @number = options[:number] || number
      @friendly_name = options[:friendly_name] || id
      @description = options[:description] || id
      @optional = options[:optional].nil? ? true : options[:optional]
      @max_length = options[:max_length]
      @pattern = options[:pattern]
    end

    def metadata
      result = { 'friendlyName' => friendly_name,
                 'description' => description,
                 'optional' => optional,
                 'returnType' => type }
      result['maxLength'] = max_length if max_length
      result['pattern'] = pattern if pattern
      result['format'] = format if format
      result
    end
  end
end
