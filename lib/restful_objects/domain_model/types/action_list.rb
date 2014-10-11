require_relative 'action_description'

module RestfulObjects
  class ActionList
    extend Forwardable

    def initialize(domain_type)
      @actions = Hash.new
      @domain_type = domain_type
    end

    def add(id, options = {})
      options[:member_order] ||= count + 1
      @actions[id] = ActionDescription.new(id, @domain_type, options)
    end

    def_delegators :@actions, :[], :each, :include?, :count, :empty?
  end
end

