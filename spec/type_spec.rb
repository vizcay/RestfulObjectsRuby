require_relative 'spec_helper'

describe RestfulObjects::Type do
  before(:all) do
    RestfulObjects::DomainModel.current.reset

    class ItemsType
      include RestfulObjects::Object
    end

    class TestType
      include RestfulObjects::Object
      property :name, :string
      collection :items, ItemsType
      action :do_something, :void
    end
  end

  subject(:domain_type) { RestfulObjects::DomainModel.current.types['TestType'] }

  it 'should generate a domain type representation' do
    type = RestfulObjects::DomainModel.current.types['TestType']
    type.friendly_name = 'A friendly name'
    type.plural_name = 'Tests Types'
    type.description = 'A description'

    expected = {
      'name' => 'TestType',
      'domainType' => 'TestType',
      'friendlyName' => 'A friendly name',
      'pluralName' => 'Tests Types',
      'description' => 'A description',
      'isService' => false,
      'members' => {
        'name' => {
          'rel' => 'urn:org.restfulobjects:rels/property',
          'href' => 'http://localhost/domain-types/TestType/properties/name',
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/property-description"',
          'method' => 'GET'
        },
        'items' => {
          'rel' => 'urn:org.restfulobjects:rels/collection',
          'href' => 'http://localhost/domain-types/TestType/collections/items',
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/collection-description"',
          'method' => 'GET'
        },
        'do_something' => {
          'rel' => 'urn:org.restfulobjects:rels/action',
          'href' => 'http://localhost/domain-types/TestType/actions/do_something',
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/action-description"',
          'method' => 'GET'
        }
      },
      'typeActions' => {

      },
      'links' => [
        { 'rel' => 'self',
          'href' => 'http://localhost/domain-types/TestType',
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/domain-type"',
          'method' => 'GET'}
      ],
      'extensions' => {}
    }

    RestfulObjects::DomainModel.current.types['TestType'].get_representation.should match_json_expression expected
  end

  context 'creating a proto-persistent object' do
    before :all do
      class ProtoPersistentTest
        include RestfulObjects::Object
        property :code, :int, optional: false
        property :name, :string, optional: false, max_length: 30
        property :value, :string
      end

      class Generator
        include RestfulObjects::Object
        action :new_object, [:proto_object, ProtoPersistentTest]
        def new_object
          rs_model.types['ProtoPersistentTest'].new_proto_persistent_object
        end
      end

      @generator = Generator.new
    end

    it 'should generate representation' do
      expected = {
        'result' => {
          'title' => 'New ProtoPersistentTest',
          'members' => {
            'code' => { 'value' => nil },
            'name' => { 'value' => nil }
          },
          'links' => [
            { 'rel' => 'urn:org.restfulobjects:rels/persist',
              'href' => 'http://localhost/objects/ProtoPersistentTest',
              'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object"',
              'method' => 'POST',
              'arguments' => {
                'members' => {
                  'code' => {
                    'value' => nil
                  },
                  'name' => {
                    'value' => nil
                  }
                }
              }
            }
          ].strict!,
          'extensions' => wildcard_matcher
        }
      }

      get "/objects/Generator/#{@generator.rs_instance_id}/actions/new_object/invoke"

      last_response.body.should match_json_expression expected
    end

    it 'should generate extension metadata' do
      expected = {
        'result' => {
          'links' => [
            { 'arguments' => {
                'members' => {
                  'name' => {
                    'extensions' => {
                      'friendlyName' => String,
                      'description' => String,
                      'returnType' => String,
                      'format' => String,
                      'optional' => false,
                      'maxLength' => Fixnum,
                      'memberOrder' => Fixnum
                    }
                  }
                }
              }
            }
          ]
        }
      }

      get "/objects/Generator/#{@generator.rs_instance_id}/actions/new_object/invoke"

      last_response.body.should match_json_expression expected
    end
  end

  it 'should persist proto-persistent object' do
    arguments_json = {
      'members' => {
        'name' => { 'value' => 'Mark Johnson' }
      }
    }.to_json

    post '/objects/TestType', {}, { input: arguments_json }

    instance_id = JSON.parse(last_response.body)['instanceId'].to_i
    created_object = RestfulObjects::DomainModel.current.objects[instance_id]
    created_object.should_not be_nil
    created_object.name.should eq('Mark Johnson')

    expected = {
      'instanceId' => created_object.object_id.to_s,
      'title' => "TestType (#{created_object.object_id})",
      'members' => {
        'name' => {
          'memberType' => 'property',
          'value' => 'Mark Johnson',
          'links' => [
            { 'rel' => 'urn:org.restfulobjects:rels/details;property="name"',
              'href' => "http://localhost/objects/TestType/#{created_object.object_id}/properties/name",
              'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object-property"',
              'method' => 'GET' }
          ],
          'extensions' => { }
        },
        'items' => {
           "memberType" => "collection",
           "size" => 1,
           "links" => [
             { 'rel' => "urn:org.restfulobjects:rels/details;collection=\"items\"",
               'href' => "http://localhost/objects/TestType/#{created_object.object_id}/collections/items",
               'type' => "application/json;profile=\"urn:org.restfulobjects:repr-types/object-collection\"",
               'method' => "GET" }
           ],
           'extensions' => { }
         },
         'do_something' => {
           'memberType' => "action",
           'links' => [
             { 'rel' => "urn:org.restfulobjects:rels/details;action=\"do_something\"",
               'href' => "http://localhost/objects/TestType/#{created_object.object_id}/actions/do_something",
               'type' => "application/json;profile=\"urn:org.restfulobjects:repr-types/object-action\"",
               'method' => "GET" }
           ],
           'extensions' => { }
        }
      },
      'links' => [
        { 'rel' => 'self',
          'href' => "http://localhost/objects/TestType/#{created_object.object_id}",
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object"',
          'method' => 'GET' },
        { 'rel' => 'describedby',
          'href' => "http://localhost/domain-types/TestType",
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/domain-type"',
          'method' => 'GET' }
      ]
    }

    last_response.body.should match_json_expression expected
  end
end
