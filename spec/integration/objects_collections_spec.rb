require_relative '../spec_helper'

describe '=> /objects/:type/:instance_id/collections/' do
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

  before(:each) do
    @collection_object = CollectionTest.new
    @item_a, @item_b, @item_c = ItemClass.new, ItemClass.new, ItemClass.new
    @item_a.ro_title = 'Item A'
    @item_b.ro_title = 'Item B'
    @item_c.ro_title = 'Item C'
  end

  describe 'GET /objects/:type/collections/:collection' do
    it 'generates response with status code 200' do
      get "/objects/CollectionTest/#{@collection_object.ro_instance_id}/collections/items"
      expect(last_response.status).to eq 200
    end

    it 'generates response with header Content-Type of object-collection' do
      get "/objects/CollectionTest/#{@collection_object.ro_instance_id}/collections/items"
      expect(last_response.headers['Content-Type']).to eq(
        'application/json;profile="urn:org.restfulobjects:repr-types/object-collection";x-ro-element-type="ItemClass"')
    end

    context 'when collection is empty,' do
      it 'generates response with an empty value array' do
        get "/objects/CollectionTest/#{@collection_object.ro_instance_id}/collections/items"
        expect(last_response.body).to match_json_expression({ value: [] })
      end
    end

    context 'when there are items in the collection,' do
      it 'generates response with a value array with the item list' do
        @collection_object.items << @item_a << @item_b << @item_c

        get "/objects/CollectionTest/#{@collection_object.ro_instance_id}/collections/items"

        expect(last_response.body).to match_json_expression({
          value: [
            { href: "http://localhost/objects/ItemClass/#{@item_a.ro_instance_id}" },
            { href: "http://localhost/objects/ItemClass/#{@item_b.ro_instance_id}" },
            { href: "http://localhost/objects/ItemClass/#{@item_c.ro_instance_id}" },
          ]
        })
      end

      it 'generates response with a value array with the item metadata' do
        item   = ItemClass.new
        item.ro_title = 'An item'
        object = CollectionTest.new
        object.items << item

        get "/objects/CollectionTest/#{object.ro_instance_id}/collections/items"

        expect(last_response.body).to match_json_expression({
          value: [ {
            rel: 'urn:org.restfulobjects:rels/value;collection="items"',
            href: "http://localhost/objects/ItemClass/#{item.ro_instance_id}",
            method: 'GET',
            type: 'application/json;profile="urn:org.restfulobjects:repr-types/object"',
            title: 'An item'
          } ]
        })
      end

      it 'generates response with object list' do
        a, b = ItemClass.new, ItemClass.new
        object = CollectionTest.new
        object.items << a << b

        get '/domain-types/CollectionTest/collections/items'
      end


      it 'generates response with links' do

      end
    end
  end

  describe 'POST /objects/:type/:instance_id/collections/:collection' do
    it 'appends objecto to collection with list semantics' do
      collection = CollectionTest.new
      item       = ItemClass.new

      post "/objects/CollectionTest/#{collection.ro_instance_id}/collections/items",
        '{ "value": { "href": "/objects/ItemClass/' + item.ro_instance_id.to_s + '" } }'

      expect(collection.items).to include(item)
    end
  end

  describe 'PUT /objects/:type/:instance_id/collections/:collection' do
    it 'appends object to collection with set semantics' do
      collection = CollectionTest.new
      item       = ItemClass.new

      put "/objects/CollectionTest/#{collection.ro_instance_id}/collections/items",
        '{ "value": { "href": "/objects/ItemClass/' + item.ro_instance_id.to_s + '" } }'

      expect(collection.items).to include(item)
    end
  end

  describe 'DELETE /objects/:type/:instance_id/collections/:collection' do
    it 'removes object from to collection' do
      collection = CollectionTest.new
      item       = ItemClass.new
      collection.items << item

      delete "/objects/CollectionTest/#{collection.ro_instance_id}/collections/items",
        '{ "value": { "href": "/objects/ItemClass/' + item.ro_instance_id.to_s + '" } }'

      expect(collection.items).not_to include(item)
    end
  end
end

describe '=> /domain-types/:type/collections/' do
  before(:all) do
    RestfulObjects::DomainModel.current.reset

    class CollectionTest
      include RestfulObjects::Object
      collection :items, 'ItemClass', friendly_name: 'item collection', description: 'a collection description'
    end
  end

  it 'generates response with collection metadata' do
    get '/domain-types/CollectionTest/collections/items'

    last_response.body.should match_json_expression({
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
      ]
    })
  end
end
