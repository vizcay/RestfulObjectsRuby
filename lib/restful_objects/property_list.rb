module RestfulObjects
  class PropertyList
    extend Forwardable

    def initialize(domain_type)
      @properties = Hash.new
      @domain_type = domain_type
    end

    def add(id, return_type, options = {})
      options[:member_order] ||= count + 1
      @properties[id] = PropertyDescription.new(id, @domain_type, return_type, options)
    end

    def_delegators :@properties, :[], :each, :include?, :count, :empty?
  end
end
