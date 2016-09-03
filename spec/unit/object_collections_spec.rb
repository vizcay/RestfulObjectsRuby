# encoding: utf-8
require_relative '../spec_helper'

describe RestfulObjects::ObjectActions do
  before :all do
    RestfulObjects::DomainModel.current.reset

    class Address
      include RestfulObjects::Object

      property :street, :string
      property :number, :int
    end

    class CollectionsTest
      include RestfulObjects::Object

      collection :addresses, Address
      collection :collection_full_metadata, Address
    end
  end

  before :each do
    @object = CollectionsTest.new
  end

  it 'should create a collection' do
    @object.addresses.is_a?(Enumerable).should be_true
    @object.addresses.empty?.should be_true

    a = Address.new
    a.street = 'Evergreen'
    a.number = 1234

    @object.addresses.push(a)
    @object.addresses.empty?.should be_false
    @object.addresses.count.should eq(1)
  end

  it 'should generate json for the collection' do
    a1 = Address.new
    @object.addresses.push a1
    a2 = Address.new
    @object.addresses.push a2
    a3 = Address.new
    @object.addresses.push a3

    expected = { 'id' => 'addresses',
                 'value' => [
                    { 'rel' => 'urn:org.restfulobjects:rels/value;collection="addresses"',
                      'href' => "http://localhost/objects/Address/#{a1.object_id}",
                      'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object"',
                      'method' => 'GET' },
                    { 'rel' => 'urn:org.restfulobjects:rels/value;collection="addresses"',
                      'href' => "http://localhost/objects/Address/#{a2.object_id}",
                      'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object"',
                      'method' => 'GET' },
                    { 'rel' => 'urn:org.restfulobjects:rels/value;collection="addresses"',
                      'href' => "http://localhost/objects/Address/#{a3.object_id}",
                      'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object"',
                      'method' => 'GET' }
                    ],
                 'links' => [
                    { 'rel' => 'self',
                      'href' => "http://localhost/objects/CollectionsTest/#{@object.object_id}/collections/addresses",
                      'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object-collection"',
                      'method' => 'GET' },
                    { 'rel' => 'up',
                      'href' => "http://localhost/objects/CollectionsTest/#{@object.object_id}",
                      'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object"',
                      'method' => 'GET' },
                    { 'rel' => 'urn:org.restfulobjects:rels/add-to;collection="addresses"',
                      'href' => "http://localhost/objects/CollectionsTest/#{@object.object_id}/collections/addresses",
                      'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object-collection"',
                      'method' => 'PUT',
                      'arguments' => { 'value' => nil } },
                    { 'rel' => 'urn:org.restfulobjects:rels/remove-from;collection="addresses"',
                      'href' => "http://localhost/objects/CollectionsTest/#{@object.object_id}/collections/addresses",
                      'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object-collection"',
                      'method' => 'DELETE',
                      'arguments' => { 'value' => nil } },
                    ]
               }

    get "/objects/CollectionsTest/#{@object.object_id}/collections/addresses"

    last_response.body.should match_json_expression expected
  end

  it 'should add an object to a collection' do
    address = Address.new

    json = { 'value' => { 'href' => "http://localhost/objects/Address/#{address.object_id}" } }.to_json

    put "/objects/CollectionsTest/#{@object.object_id}/collections/addresses", {}, { input: json }

    @object.addresses.include?(address).should be_true

    expected = { 'id' => 'addresses',
                 'value' => [
                    { 'rel' => 'urn:org.restfulobjects:rels/value;collection="addresses"',
                      'href' => "http://localhost/objects/Address/#{address.object_id}",
                      'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object"',
                      'method' => 'GET' } ],
                 'links' => [
                    { 'rel' => 'self',
                      'href' => "http://localhost/objects/CollectionsTest/#{@object.object_id}/collections/addresses",
                      'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object-collection"',
                      'method' => 'GET' },
                    { 'rel' => 'up',
                      'href' => "http://localhost/objects/CollectionsTest/#{@object.object_id}",
                      'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object"',
                      'method' => 'GET' },
                    { 'rel' => 'urn:org.restfulobjects:rels/add-to;collection="addresses"',
                      'href' => "http://localhost/objects/CollectionsTest/#{@object.object_id}/collections/addresses",
                      'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object-collection"',
                      'method' => 'PUT',
                      'arguments' => { 'value' => nil } },
                    { 'rel' => 'urn:org.restfulobjects:rels/remove-from;collection="addresses"',
                      'href' => "http://localhost/objects/CollectionsTest/#{@object.object_id}/collections/addresses",
                      'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object-collection"',
                      'method' => 'DELETE',
                      'arguments' => { 'value' => nil } },
                    ]
               }

    last_response.body.should match_json_expression expected
  end

  it 'should remove an object from a collection' do
    address = Address.new

    @object.addresses.push(address)

    json = { 'value' => { 'href' => "http://localhost/objects/Address/#{address.object_id}" } }.to_json

    delete "/objects/CollectionsTest/#{@object.object_id}/collections/addresses", {}, { input: json }

    @object.addresses.include?(address).should be_false

    expected = { 'id' => 'addresses',
                 'value' => [],
                 'links' => [
                    { 'rel' => 'self',
                      'href' => "http://localhost/objects/CollectionsTest/#{@object.object_id}/collections/addresses",
                      'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object-collection"',
                      'method' => 'GET' },
                    { 'rel' => 'up',
                      'href' => "http://localhost/objects/CollectionsTest/#{@object.object_id}",
                      'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object"',
                      'method' => 'GET' },
                    { 'rel' => 'urn:org.restfulobjects:rels/add-to;collection="addresses"',
                      'href' => "http://localhost/objects/CollectionsTest/#{@object.object_id}/collections/addresses",
                      'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object-collection"',
                      'method' => 'PUT',
                      'arguments' => { 'value' => nil } },
                    { 'rel' => 'urn:org.restfulobjects:rels/remove-from;collection="addresses"',
                      'href' => "http://localhost/objects/CollectionsTest/#{@object.object_id}/collections/addresses",
                      'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object-collection"',
                      'method' => 'DELETE',
                      'arguments' => { 'value' => nil } },
                    ]
               }

    last_response.body.should match_json_expression expected
  end

  it 'should generate metadata in extensions' do
    collection = @object.ro_domain_type.collections['collection_full_metadata']
    collection.friendly_name = 'Friendly Collection'
    collection.description = 'Collection Description'
    collection.plural_form = 'Collections'
    expected = {
      'id' => 'collection_full_metadata',
      'extensions' => {
        'friendlyName' => 'Friendly Collection',
        'description' => 'Collection Description',
        'returnType' => 'list',
        'elementType' => 'Address',
        'pluralForm' => 'Collections',
        'memberOrder' => Fixnum
      }.strict!
    }

    get "/objects/ActionsTest/#{@object.object_id}/collections/collection_full_metadata"

    last_response.body.should match_json_expression expected
  end
end

