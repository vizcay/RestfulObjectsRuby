require_relative 'spec_helper'

describe RestfulObjects::ObjectActions do
  before :all do
    RestfulObjects::DomainModel.current.reset

    class ActionResult
      include RestfulObjects::Object
    end

    class ActionsTest
      include RestfulObjects::Object

      property :string_prop, :string
      property :int_prop, :int
      property :decimal_prop, :decimal
      property :date_prop, :date
      property :blob_prop, :blob

      action :string_action, :string
      action :int_action, :int
      action :decimal_action, :decimal
      action :date_action, :date
      action :blob_action, :blob

      def string_action
        string_prop
      end

      def int_action
        int_prop
      end

      def decimal_action
        decimal_prop
      end

      def date_action
        date_prop
      end

      def blob_action
        blob_prop
      end

      action :multiply, :int, { 'arg1' => :int, 'arg2' => :int }
      action :get_nil_scalar, :int
      action :get_object, [:object, ActionResult]
      action :get_nil_object, [:object, ActionResult]
      action :get_list, [:list, ActionResult]
      action :get_nil_list, [:list, ActionResult]

      def multiply(arg1, arg2)
        arg1 * arg2
      end

      def get_nil_scalar
        nil
      end

      def get_object
        @cached ||= ActionResult.new
      end

      def get_nil_object
        nil
      end

      def get_list
        @cached ||= [ActionResult.new, ActionResult.new]
      end

      def get_nil_list
        nil
      end
    end
  end

  before :each do
    @object = ActionsTest.new
  end

  it 'should get action' do
    expected = {
      'id' => 'multiply',
      'parameters' => {
        'arg1' => {
          'links' => [],
          'extensions' => { }
        },
        'arg2' => {
          'links' => [],
          'extensions' => { }
        },
      },
      'links' => [
          { 'rel' => 'self',
            'href' => "http://localhost/objects/ActionsTest/#{@object.object_id}/actions/multiply",
            'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object-action"',
            'method' => 'GET' },
          { 'rel' => 'up',
            'href' => "http://localhost/objects/ActionsTest/#{@object.object_id}",
            'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object"',
            'method' => 'GET' },
          {
            'rel' => 'urn:org.restfulobjects:rels/invoke;action="multiply"',
            'href' => "http://localhost/objects/ActionsTest/#{@object.object_id}/actions/multiply/invoke",
            'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/action-result"',
            'method' => 'GET',
            'arguments' => {
              'arg1' => { 'value' => nil },
              'arg2' => { 'value' => nil }
            }
          }
      ]
    }

    get "/objects/ActionsTest/#{@object.object_id}/actions/multiply"

    last_response.body.should match_json_expression expected
  end

  it 'should process different actions result types' do
    @object.string_prop = 'A string'
    @object.int_prop = 1234
    @object.decimal_prop = 333.33
    @object.date_prop = Date.new(2012, 2, 29)
    @object.blob_prop = "\xE5\xA5\xB4\x30\xF2\x8C\x71\xD9"

    expected = {
      'string_action' => 'A string',
      'int_action' => 1234,
      'decimal_action' => 333.33,
      'date_action' => '2012-02-29',
      'blob_action' => '5aW0MPKMcdk=' }

    expected.each do |action, value|
      get "/objects/ActionsTest/#{@object.object_id}/actions/#{action}/invoke"
      JSON.parse(last_response.body)['result']['value'].should eq value
    end
  end

  it 'should invoke action (get) with simple arguments as a query string' do
    expected = {
      'resultType' => 'scalar',
      'result' => {
        'value' => 28,
      }
    }

    get "/objects/ActionsTest/#{@object.object_id}/actions/multiply/invoke?arg1=4&arg2=7"

    last_response.body.should match_json_expression expected
  end

  it 'should invoke action get with arguments returning scalar' do
    arguments = { 'arg1' => { 'value' => 3 },
                  'arg2' => { 'value' => 9 } }.to_json

    expected = {
      'links' => [
        { 'rel' => 'self',
          'href' => "http://localhost/objects/ActionsTest/#{@object.object_id}/actions/multiply/invoke",
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/action-result"',
          'arguments' =>
            { 'arg1' => { 'value' => 3 },
              'arg2' => { 'value' => 9 } },
          'method' => 'GET' }
      ],
      'resultType' => 'scalar',
      'result' => {
        'links' => [
          { 'rel' => 'urn:org.restfulobjects:rels/return-type',
            'href' => 'http://localhost/domain-types/int',
            'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/domain-type"',
            'method' => 'GET' } ],
        'value' => 27,
        'extensions' => { }
      },
      'extensions' => {}
    }

    get "/objects/ActionsTest/#{@object.object_id}/actions/multiply/invoke", {}, {input: arguments}

    last_response.body.should match_json_expression expected
  end

  it 'should invoke action and return a null scalar representation' do
    expected = {
      'links' => [
        { 'rel' => 'self',
          'href' => "http://localhost/objects/ActionsTest/#{@object.object_id}/actions/get_nil_scalar/invoke",
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/action-result"',
          'method' => 'GET',
          'arguments' => nil }
      ],
      'resultType' => 'scalar',
      'result' => nil,
      'extensions' => {}
    }

    get "/objects/ActionsTest/#{@object.object_id}/actions/get_nil_scalar/invoke"

    last_response.body.should match_json_expression expected
  end

  it 'should invoke action and return an object representation' do
    action_result = @object.get_object

    expected = {
      'links' => [
        { 'rel' => 'self',
          'href' => "http://localhost/objects/ActionsTest/#{@object.object_id}/actions/get_object/invoke",
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/action-result"',
          'method' => 'GET',
          'arguments' => nil }
      ],
      'resultType' => 'object',
      'result' => {
        'instanceId' => "#{action_result.object_id}",
        'links' => [
          { 'rel' => 'self',
            'href' => "http://localhost/objects/ActionResult/#{action_result.object_id}",
            'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object"',
            'method' => 'GET' },
          { 'rel' => 'describedby',
            'href' => "http://localhost/domain-types/ActionResult",
            'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/domain-type"',
            'method' => 'GET' }
        ],
        'members' => wildcard_matcher
      }
    }

    get "/objects/ActionsTest/#{@object.object_id}/actions/get_object/invoke"

    last_response.body.should match_json_expression expected
  end

  it 'should invoke action and return a null object representation' do
    expected = {
      'links' => [
        { 'rel' => 'self',
          'href' => "http://localhost/objects/ActionsTest/#{@object.object_id}/actions/get_nil_object/invoke",
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/action-result"',
          'method' => 'GET',
          'arguments' => nil }
      ],
      'resultType' => 'object',
      'result' => nil,
      'extensions' => { }
    }

    get "/objects/ActionsTest/#{@object.object_id}/actions/get_nil_object/invoke"

    last_response.body.should match_json_expression expected
  end

  it 'should invoke action and return a list representation' do
    action_result = @object.get_list

    expected = {
      'links' => [
        { 'rel' => 'self',
          'href' => "http://localhost/objects/ActionsTest/#{@object.object_id}/actions/get_list/invoke",
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/action-result"',
          'method' => 'GET',
          'arguments' => nil }
      ],
      'resultType' => 'list',
      'result' => {
        'links' => [
          { 'rel' => 'urn:org.restfulobjects:rels/element-type',
            'href' => "http://localhost/domain-types/ActionResult",
            'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/domain-type"',
            'method' => 'GET' } ],
        'value' => [
          { 'rel' =>'urn:org.restfulobjects:rels/element',
            'href' => "http://localhost/objects/ActionResult/#{action_result[0].object_id}",
            'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object"',
            'method' => 'GET' },
          { 'rel' =>'urn:org.restfulobjects:rels/element',
            'href' => "http://localhost/objects/ActionResult/#{action_result[1].object_id}",
            'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object"',
            'method' => 'GET' }
        ],
        'extensions' => { }
      },
      'extensions' => { }
    }

    get "/objects/ActionsTest/#{@object.object_id}/actions/get_list/invoke"

    last_response.body.should match_json_expression expected
  end

  it 'should invoke action and return a null list respresentation' do
    expected = {
      'links' => [
        { 'rel' => 'self',
          'href' => "http://localhost/objects/ActionsTest/#{@object.object_id}/actions/get_nil_list/invoke",
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/action-result"',
          'method' => 'GET',
          'arguments' => nil }
      ],
      'resultType' => 'list',
      'result' => nil,
      'extensions' => { }
    }

    get "/objects/ActionsTest/#{@object.object_id}/actions/get_nil_list/invoke"

    last_response.body.should match_json_expression expected
  end

  it 'should generate metadata in extensions' do
    class ActionsTest
      action :action_full_metadata, :string, {}, friendly_name: 'Meta Action', description: 'To Test Metadata'
    end

    expected = {
      'id' => 'action_full_metadata',
      'extensions' => {
        'friendlyName' => 'Meta Action',
        'description' => 'To Test Metadata',
        'returnType' => 'string',
        'hasParams' => false,
        'memberOrder' => Fixnum
      }.strict!
    }

    get "/objects/ActionsTest/#{@object.object_id}/actions/action_full_metadata"

    last_response.body.should match_json_expression expected
  end

  it 'should generate metadata for parameters in extensions' do
    class ActionsTest
      action :metadata_test, :void, { param1: :string,
                                      param2: [:int, { optional: false, friendly_name: 'friendly', description: 'description' }],
                                      param3: ActionResult }
    end

    expected = {
      'id' => 'metadata_test',
      'parameters' => {
        'param1' => {
          'extensions' => {
            'friendlyName' => 'param1',
            'description' => 'param1',
            'returnType' => 'string',
            'optional' => true
          }
        },
        'param2' => {
          'extensions' => {
            'friendlyName' => 'friendly',
            'description' => 'description',
            'returnType' => 'int',
            'optional' => false
          },
        },
        'param3' => {
          'extensions' => {
            'friendlyName' => 'param3',
            'description' => 'param3',
            'returnType' => 'ActionResult',
            'optional' => true
          }
        }
      }
    }

    get "/objects/ActionsTest/#{@object.object_id}/actions/metadata_test"

    last_response.body.should match_json_expression expected
  end
end
