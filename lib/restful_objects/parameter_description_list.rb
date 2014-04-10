module RestfulObjects
  class ParameterDescriptionList
    extend Forwardable

    def initialize
      @parameters = Hash.new
    end

    def add(id, definition)
      @parameters[id] = ParameterDescription.new(id, definition, count + 1)
    end

    def_delegators :@parameters, :[], :each, :include?, :count, :empty?
  end
end
