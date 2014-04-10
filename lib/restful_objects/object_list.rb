module RestfulObjects
  class ObjectList
    extend Forwardable

    def initialize(base_url)
      @objects = Hash.new
      @base_url = base_url
    end

    def register(instance, service = false)
      @objects[instance.object_id] = instance
    end

    def_delegators :@objects, :[], :each, :include?, :count, :clear, :empty?, :keys, :values
  end
end
