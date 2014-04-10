module RestfulObjects
  class ActionList
    extend Forwardable

    def initialize(domain_type)
      @actions = Hash.new
      @domain_type = domain_type
    end

    def add(id, result_type, parameters = {}, options = {})
      options[:member_order] ||= count + 1
      @actions[id] = ActionDescription.new(id, result_type, @domain_type, parameters, options)
    end

    def_delegators :@actions, :[], :each, :include?, :count, :empty?
  end
end
