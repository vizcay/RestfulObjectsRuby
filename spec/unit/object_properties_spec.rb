require_relative '../spec_helper'

describe RestfulObjects::ObjectProperties do
  before :all do
    RestfulObjects::DomainModel.current.reset

    class PropertiesTest
      include RestfulObjects::Object

      property :id, :int, read_only: true
      property :name, :string, max_length: 10
      property :string_prop, :string
      property :int_prop, :int
      property :decimal_prop, :decimal
      property :date_prop, :date
      property :blob_prop, :blob

      property :prop_full_metadata, :string, friendly_name: 'Meta Prop', description: 'To Test Metadata', max_length: 30,
                                             pattern: '.*abc.*', optional: false

      def initialize
        super
        @id = 99
      end
    end
  end

  before :each do
    @object = PropertiesTest.new
  end

  it 'should respond to properties' do
    @object.respond_to?(:string_prop).should be_true
    @object.respond_to?(:string_prop=).should be_true
  end

  it 'should not generate writer for read-only property' do
    @object.respond_to?(:id).should be_true
    @object.respond_to?(:id=).should be_false
  end

  it 'should generate json for a read-only property' do
    expected = { 'id' =>
                 { 'value' => 99,
                   'links' => [
                      { 'rel' => 'self',
                        'href' => "http://localhost/objects/PropertiesTest/#{@object.object_id}/properties/id",
                        'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object-property"',
                        'method' => 'GET'},
                      { 'rel' => 'up',
                        'href' => "http://localhost/objects/PropertiesTest/#{@object.object_id}",
                        'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object"',
                        'method' => 'GET'}
                    ],
                    'disabledReason' => 'read-only property'
                 }
               }

    get "/objects/PropertiesTest/#{@object.object_id}/properties/id"

    last_response.body.should match_json_expression expected
  end

  it 'should generate json for a writable property' do
    @object.name = 'Mr. John'

    expected = { 'name' =>
                 { 'value' => 'Mr. John',
                   'links' => [
                      { 'rel' => 'self',
                        'href' => "http://localhost/objects/PropertiesTest/#{@object.object_id}/properties/name",
                        'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object-property"',
                        'method' => 'GET' },
                      { 'rel' => 'up',
                        'href' => "http://localhost/objects/PropertiesTest/#{@object.object_id}",
                        'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object"',
                        'method' => 'GET' },
                      { 'rel' => 'urn:org.restfulobjects:rels/modify;property="name"',
                        'href' => "http://localhost/objects/PropertiesTest/#{@object.object_id}/properties/name",
                        'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object-property"',
                        'method' => 'PUT',
                        'arguments' => { 'value' => nil } },
                      { 'rel' => 'urn:org.restfulobjects:rels/clear;property="name"',
                        'href' => "http://localhost/objects/PropertiesTest/#{@object.object_id}/properties/name",
                        'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object-property"',
                        'method' => 'DELETE' }
                    ]
                 }
               }

    get "/objects/PropertiesTest/#{@object.object_id}/properties/name"

    last_response.body.should match_json_expression expected
  end

  it 'should enforce string property max_length' do
    @object.name = 'x' * 10
    @object.name.should eq('x' * 10)
    expect { @object.name = 'x' * 11 }.to raise_error
  end

  it 'should process different property types get' do
    @object.string_prop = 'A string'
    @object.int_prop = 1234
    @object.decimal_prop = 333.33
    @object.date_prop = Date.new(2012, 2, 29)
    @object.blob_prop = "\xE5\xA5\xB4\x30\xF2\x8C\x71\xD9"

    expected = {
      'string_prop' => 'A string',
      'int_prop' => 1234,
      'decimal_prop' => 333.33,
      'date_prop' => '2012-02-29',
      'blob_prop' => '5aW0MPKMcdk=' }

    expected.each do |name, value|
      get "/objects/PropertiesTest/#{@object.object_id}/properties/#{name}"
      JSON.parse(last_response.body)[name]['value'].should eq value
    end
  end

  it 'should process different property types set' do
    values = {
      'string_prop' => 'A string',
      'int_prop' => 1234,
      'decimal_prop' => 333.33,
      'date_prop' => '2012-02-29',
      'blob_prop' => '5aW0MPKMcdk=' }

    values.each do |name, value|
      put "/objects/PropertiesTest/#{@object.object_id}/properties/#{name}", { 'value' => value }.to_json
    end

    @object.string_prop.should eq 'A string'
    @object.int_prop.should eq 1234
    @object.decimal_prop.should eq 333.33
    @object.date_prop.should eq Date.new(2012, 2, 29)
    @object.blob_prop.should eq "\xE5\xA5\xB4\x30\xF2\x8C\x71\xD9"
  end

  it 'should process a property put with json' do
    json = { 'value' => 'masterkey' }.to_json

    expected = { 'name' =>
                 { 'value' => 'masterkey',
                   'links' => [
                      { 'rel' => 'self',
                        'href' => "http://localhost/objects/PropertiesTest/#{@object.object_id}/properties/name",
                        'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object-property"',
                        'method' => 'GET' },
                      { 'rel' => 'up',
                        'href' => "http://localhost/objects/PropertiesTest/#{@object.object_id}",
                        'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object"',
                        'method' => 'GET' },
                      { 'rel' => 'urn:org.restfulobjects:rels/modify;property="name"',
                        'href' => "http://localhost/objects/PropertiesTest/#{@object.object_id}/properties/name",
                        'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object-property"',
                        'method' => 'PUT',
                        'arguments' => { 'value' => nil } },
                      { 'rel' => 'urn:org.restfulobjects:rels/clear;property="name"',
                        'href' => "http://localhost/objects/PropertiesTest/#{@object.object_id}/properties/name",
                        'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object-property"',
                        'method' => 'DELETE' }
                    ]
                 }
               }

    put "/objects/PropertiesTest/#{@object.object_id}/properties/name", json

    last_response.body.should match_json_expression expected
  end

  it 'should process a property delete' do
    @object.name = 'irrelevant'

    delete "/objects/PropertiesTest/#{@object.object_id}/properties/name"

    @object.name.should be_nil

    expected = { 'name' => { 'value' => nil } }

    last_response.body.should match_json_expression expected
  end

  it 'should generate metadata in extensions' do
    expected = {
      'prop_full_metadata' => {
        'extensions' => {
          'friendlyName' => 'Meta Prop',
          'description' => 'To Test Metadata',
          'returnType' => 'string',
          'format' => 'string',
          'optional' => false,
          'maxLength' => 30,
          'pattern' => '.*abc.*',
          'memberOrder' => Fixnum
        }.strict!
      }
    }

    get "/objects/PropertiesTest/#{@object.object_id}/properties/prop_full_metadata"

    last_response.body.should match_json_expression expected
  end
end

