module RestfulObjects
  class CollectionList
    extend Forwardable

    def initialize(domain_type)
      @domain_type = domain_type
      @collections = Hash.new
    end

    def add(name, type, options = {})
      options[:member_order] ||= count + 1
      @collections[name] = CollectionDescription.new(name, type, @domain_type, options)
    end

    def_delegators :@collections, :[], :each, :each_key, :each_value, :include?, :count, :empty?, :clear
  end
end
