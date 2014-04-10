module RestfulObjects
  class TypeList
    extend Forwardable
    include LinkGenerator

    def initialize
      @types = Hash.new
    end

    def add(name)
      @types[name] = Type.new(name)
    end

    def get_representation
      response =  {
       'links' => [
          link_to(:self, '/domain-types', :type_list),
          link_to(:up, '/', :homepage),
        ],
        'value' => []
      }

      each { |name, type| response['value'] << link_to(:domain_type, "/domain-types/#{name}", :domain_type) }

      response.to_json
    end

    def_delegators :@types, :[], :each, :include?, :size?, :clear, :empty?
  end
end
