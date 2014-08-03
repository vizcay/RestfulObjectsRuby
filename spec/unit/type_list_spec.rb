# encoding: utf-8
require_relative '../spec_helper'

describe RestfulObjects::TypeList do
  before(:all) do
    RestfulObjects::DomainModel.current.reset

    class DomainObject
      include RestfulObjects::Object
    end
  end

  it 'should generate domain types list resource' do
    expected = {
      'links' => [
        { 'rel' => 'self',
          'href' => 'http://localhost/domain-types',
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/type-list"',
          'method' => 'GET' },
        { 'rel' => 'up',
          'href' => 'http://localhost/',
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/homepage"',
          'method' => 'GET' }
      ],
      'value' => [
        { 'rel' => 'urn:org.restfulobjects:rels/domain-type',
          'href' => "http://localhost/domain-types/#{DomainObject}",
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/domain-type"',
          'method' => 'GET' }
      ],
      'extensions' => {}
    }.to_json

    RestfulObjects::DomainModel.current.types.get_representation
  end
end

