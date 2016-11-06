require_relative 'parameter_description'

class RestfulObjects::ParameterDescriptionList
  extend Forwardable

  def initialize
    @parameters = Hash.new
  end

  def add(id, definition)
    @parameters[id] = RestfulObjects::ParameterDescription.new(id, definition, count + 1)
  end

  def_delegators :@parameters, :[], :each, :include?, :count, :empty?
end
