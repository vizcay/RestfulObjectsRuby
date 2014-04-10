require_relative 'spec_helper'

describe RestfulObjects::Service do
  before :all do
    RestfulObjects::DomainModel.current.reset

    class ServiceTest
      include RestfulObjects::Service

      action :do_something

      def do_something
      end
    end
  end

  it 'should be registered and created automatically ' do
    RestfulObjects::DomainModel.current.services.include?('ServiceTest').should be_true
    RestfulObjects::DomainModel.current.services['ServiceTest'].should_not be_nil
    RestfulObjects::DomainModel.current.services['ServiceTest'].is_service.should be_true
  end

  it 'should generate json for the service' do
    service = RestfulObjects::DomainModel.current.services['ServiceTest']
    service.title = 'Test Service'

    expected = {
      'serviceId' => 'ServiceTest',
      'title' => 'Test Service',
      'members' => {
        'do_something' => {
          'memberType' => 'action',
          'links' => [
            { 'rel' => 'urn:org.restfulobjects:rels/details;action="do_something"',
              'href' => "http://localhost/services/ServiceTest/actions/do_something",
              'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object-action"',
              'method' => 'GET' }
          ],
          'extensions' => { }
        }
      },
      'links' => [
        { 'rel' => 'self',
          'href' => "http://localhost/services/ServiceTest",
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object"',
          'method' => 'GET' },
        { 'rel' => 'describedby',
          'href' => "http://localhost/domain-types/ServiceTest",
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/domain-type"',
          'method' => 'GET' }
      ]
    }

    get '/services/ServiceTest'
    last_response.body.should match_json_expression expected
  end

  it 'should not be registered as an object' do
    class ServiceTest
      include RestfulObjects::Service
    end
    instance_id = model.services['ServiceTest'].rs_instance_id
    model.objects.include?(instance_id).should_not be_true
  end

  it 'should generate action representation to links to services invokation' do
    class ServiceTest
      include RestfulObjects::Service
      action :do_something, :void
    end

    get '/services/ServiceTest/actions/do_something'

    expected = {
      'links' => [
          { 'rel' => 'self',
            'href' => "http://localhost/services/ServiceTest/actions/do_something",
            'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object-action"',
            'method' => 'GET' },
          { 'rel' => 'up',
            'href' => "http://localhost/services/ServiceTest",
            'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object"',
            'method' => 'GET' },
          {
            'rel' => 'urn:org.restfulobjects:rels/invoke;action="do_something"',
            'href' => "http://localhost/services/ServiceTest/actions/do_something/invoke",
            'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/action-result"',
            'method' => 'GET' }
      ]
    }

    last_response.body.should match_json_expression expected
  end

  it 'should process action from service route' do
    class ServiceTest
      include RestfulObjects::Service
      action :do_something, :int
      def do_something
        @something_done = true
        10
      end
    end

    get "/services/ServiceTest/actions/do_something/invoke"

    last_response.body.should match_json_expression( {'resultType' => 'scalar', 'result' => { 'value' => 10 } } )
  end

  it 'should call initialize on service' do
    class InitializedService
      include RestfulObjects::Service
      attr_reader :init_called
      def initialize
        super
        @init_called = true
        @title = 'A title'
      end
    end
    model.services['InitializedService'].init_called.should be_true
    model.services['InitializedService'].title.should eq 'A title'
  end
end
