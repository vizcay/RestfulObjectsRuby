module RestfulObjects
  class ServiceList
    extend Forwardable
    include LinkGenerator

    def initialize(base_url)
      @services = Hash.new
      @base_url = base_url
    end

    def register(service)
      raise 'service registration should be done with a class' if not service.is_a? Class
      @services[service.name] = service
    end

    def get_list
      representation = {
        'links' => [
          link_to(:self, '/services', :services),
          link_to(:up, '/', :homepage),
        ],
        'value' => generate_values,
        'extensions' => { }
      }.to_json
    end

    def [](key)
      value = @services[key]
      if value.is_a? Class
        value = value.new
        @services[key] = value
      end
      value
    end

    def_delegators :@services, :each, :include?, :count, :empty?, :clear

    private

      def generate_values
        ensure_all_created
        values = []
        each do |name, service|
          element = link_to(:service, "/services/#{name}", :object, service_id: name)
          element['title'] = service.title
          values << element
        end
        values
      end

      def ensure_all_created
        @services.each { |name, value| @services[name] = value.new if value.is_a? Class }
      end
  end
end
