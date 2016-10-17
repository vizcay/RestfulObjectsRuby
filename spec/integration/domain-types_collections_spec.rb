require_relative '../spec_helper'

describe '/domain-types/:type/collections/' do
  before(:all) do
    RestfulObjects::DomainModel.current.reset

    class ItemClass
      include RestfulObjects::Object
    end

    class CollectionTest
      include RestfulObjects::Object
      collection :items, 'ItemClass', friendly_name: 'item collection', description: 'a collection description'
    end
  end

  describe 'GET /domain-types/:type/collections/:collection' do
    it 'generates response with object list' do
      a, b = ItemClass.new, ItemClass.new
      object = CollectionTest.new
      object.items << a << b

      get '/domain-types/CollectionTest/collections/items'
    end

    it 'generates response with collection metadata' do
      expected = {
        'id' => 'items',
        'friendlyName' => 'item collection',
        'description' => 'a collection description',
        'memberOrder' => 1,
        'links' => [
          { 'rel' => 'self',
            'href' => 'http://localhost/domain-types/CollectionTest/collections/items',
            'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/collection-description"',
            'method' => 'GET' },
          { 'rel' => 'up',
            'href' => 'http://localhost/domain-types/CollectionTest',
            'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/domain-type"',
            'method' => 'GET' },
          { 'rel' => 'urn:org.restfulobjects:rels/return-type',
            'href' => 'http://localhost/domain-types/list',
            'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/domain-type"',
            'method' => 'GET' },
          { 'rel' => 'urn:org.restfulobjects:rels/element-type',
            'href' => 'http://localhost/domain-types/ItemClass',
            'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/domain-type"',
            'method' => 'GET' }
        ],
        'extensions' => wildcard_matcher
      }

      get '/domain-types/CollectionTest/collections/items'
      last_response.body.should match_json_expression expected
    end

    it 'generates response with links' do

    end
  end

  describe 'POST /domain-types/:type/collections/:collection' do
    it 'appends objecto to collection with list semantics' do
    end
  end

  describe 'PUT /domain-types/:type/collections/:collection' do
    it 'appends objecto to collection with set semantics' do
    end
  end

  describe 'DELETE /domain-types/:type/collections/:collection' do
    it 'removes object from to collection' do
    end
  end
end
