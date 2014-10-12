require_relative 'helpers/link_generator'
require_relative 'user'
require_relative 'mixins/object'
require_relative 'mixins/service'
require_relative 'types/domain_type'

module RestfulObjects
  class DomainModel
    include LinkGenerator

    attr_accessor :base_url, :compatible_mode
    attr_reader :metadata_schema, :version, :user, :types, :services, :objects

    def self.current
      @current ||= DomainModel.new
    end

    def self.current=(value)
      @current = value
    end

    def initialize
      @base_url        = 'http://localhost'
      @metadata_schema = :selectable
      @compatible_mode = false
      @user            = User.new(@base_url, 'anonymous')
      @types           = {}
      @services        = {}
      @objects         = {}
      @services.instance_eval do
        alias :base_accesor :[]

        def [](key)
          value = base_accesor(key)
          if value.is_a?(Class)
            value = value.new
            self[key] = value
          end
          value
        end
      end
    end

    def register_object(instance)
      @objects[instance.object_id] = instance
    end

    def register_service(service)
      raise 'service registration should be done with a class' unless service.is_a?(Class)
      @services[service.name] = service
    end

    def register_type(name)
      @types[name] = DomainType.new(name)
    end

    def get_homepage
      { 'links' => [
          link_to(:self, '/', :homepage),
          link_to(:user, '/user', :user),
          link_to(:services, '/services', :list),
          link_to(:version, '/version', :version),
          link_to(:domain_types, '/domain-types', :type_list)
        ],
       'extensions' => {}
      }.to_json
    end

    def get_version
      { 'links' => [
          link_to(:self, '/version', :version),
          link_to(:up, '/', :homepage),
        ],
        'specVersion' => '1.0',
        'optionalCapabilities' => {
          'blobsClobs' => true,
          'deleteObjects' => true,
          'domainModel' => metadata_schema.to_s,
          'protoPersistentObjects' => true,
          'validateOnly' => false
        },
        'extensions' => {}
      }.to_json
    end

    def get_user
      @user.get_as_json
    end

    def get_services
      { 'links' => [
           link_to(:self, '/services', :services),
           link_to(:up, '/', :homepage),
         ],
         'value' => services_generate_values,
         'extensions' => { }
      }.to_json
    end

    def get_type_list_representation
      { 'links'  => [link_to(:self, '/domain-types', :type_list), link_to(:up, '/', :homepage)],
         'value' => @types.map { |name| link_to(:domain_type, "/domain-types/#{name}", :domain_type) }
      }.to_json
    end

    def metadata_schema=(value)
      if not [:simple, :formal, :selectable].include?(value)
        raise "invalid metadata schema, choose :simple, :formal or :selectable"
      end
      @metadata_schema = value
    end

    def reset
      @base_url = 'http://localhost'
      @user     = nil
      @types.clear
      @services.clear
      @objects.clear
    end

    def reset_objects
      @objects.clear
    end

    private

    def services_generate_values
      services_ensure_all_created
      values = []
      @services.each do |name, service|
        element = link_to(:service, "/services/#{name}", :object, service_id: name)
        element['title'] = service.title
        values << element
      end
      values
    end

    def services_ensure_all_created
      @services.each { |name, value| @services[name] = value.new if value.is_a? Class }
    end
  end
end

