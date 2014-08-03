# encoding: utf-8
require_relative '../spec_helper'

describe '/domain-types/:type/collections/:collection' do
  before(:all) do
    RestfulObjects::DomainModel.current.reset
  end

  it 'should generate a collection description representation' do
    class CollectionTest
      include RestfulObjects::Object
      collection :items, 'ItemClass', friendly_name: 'item collection', description: 'a collection description'
    end

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
end

