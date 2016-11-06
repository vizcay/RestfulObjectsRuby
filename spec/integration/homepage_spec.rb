require_relative '../spec_helper'

describe '=> /' do
  before(:all) do
    RestfulObjects::DomainModel.current.reset
  end

  it 'should generate a homepage resource' do
    homepage = {
      'links' => [
        { 'rel' => 'self',
          'href' => 'http://localhost/',
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/homepage"',
          'method' => 'GET' },
        { 'rel' => 'urn:org.restfulobjects:rels/user',
          'href' => 'http://localhost/user',
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/user"',
          'method' => 'GET' },
        { 'rel' => 'urn:org.restfulobjects:rels/services',
          'href' => 'http://localhost/services',
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/list"',
          'method' => 'GET' },
        { 'rel' => 'urn:org.restfulobjects:rels/version',
          'href' => 'http://localhost/version',
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/version"',
          'method' => 'GET' },
        { 'rel' => 'urn:org.restfulobjects:rels/domain-types',
          'href' => 'http://localhost/domain-types',
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/type-list"',
          'method' => 'GET' },
      ],
      'extensions' => { }
    }

    get '/'
    last_response.body.should match_json_expression homepage
  end

  it 'should generate a version resource' do
    version = {
      'links' => [
        { 'rel' => 'self',
          'href' => 'http://localhost/version',
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/version"',
          'method' => 'GET' },
        { 'rel' => 'up',
          'href' => 'http://localhost/',
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/homepage"',
          'method' => 'GET' }
      ],
      'specVersion' => '1.0',
      'optionalCapabilities' => {
        'blobsClobs' => true,
        'deleteObjects' => true,
        'domainModel' => 'selectable',
        'protoPersistentObjects' => true,
        'validateOnly' => false
      },
      'extensions' => {}
    }

    get '/version'
    last_response.body.should match_json_expression version
  end

  it 'should generate a services list resource' do
    class ServiceTest
      include RestfulObjects::Service
    end

    RestfulObjects::DomainModel.current.services['ServiceTest'].ro_title = 'Service Test Title'

    services_list = {
      'links' => [
        { 'rel' => 'self',
          'href' => 'http://localhost/services',
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/services"',
          'method' => 'GET' },
        { 'rel' => 'up',
          'href' => 'http://localhost/',
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/homepage"',
          'method' => 'GET' }
      ],
      'value' => [
        { 'rel' => 'urn:org.restfulobjects:rels/service;serviceId="ServiceTest"',
          'href' => 'http://localhost/services/ServiceTest',
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object"',
          'method' => 'GET',
          'title' => 'Service Test Title' }
      ],
      'extensions' => { }
    }

    get '/services'
    last_response.body.should match_json_expression services_list
  end
end
