require_relative '../spec_helper'

describe RestfulObjects::Object do
  before :each do
    RestfulObjects::DomainModel.current.reset
  end

  it 'generates json representation for a complex object' do
    class Address
    end

    class ObjectTest
      include RestfulObjects::Object

      property :id, :int, read_only: true
      property :password, :string, max_length: 10

      action :hash_password, return_type: :string

      collection :addresses, Address

      def initialize
        @id = 99
        super
      end
    end

    object          = ObjectTest.new
    object.password = 'secret_key'
    address         = Address.new
    object.addresses.push(address)

    get "/objects/ObjectTest/#{object.object_id}"

    expected = {
      'instanceId' => object.object_id.to_s,
      'title' => "ObjectTest (#{object.object_id})",
      'members' => {
        'id' =>
          { 'memberType' => 'property',
            'value' => 99,
            'disabledReason' => 'read-only property',
            'links' => [
              { 'rel' => 'urn:org.restfulobjects:rels/details;property="id"',
                'href' => "http://localhost/objects/ObjectTest/#{object.object_id}/properties/id",
                'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object-property"',
                'method' => 'GET' }
            ],
          'extensions' => { }
        },
        'password' => {
          'memberType' => 'property',
          'value' => 'secret_key',
          'links' => [
            { 'rel' => 'urn:org.restfulobjects:rels/details;property="password"',
              'href' => "http://localhost/objects/ObjectTest/#{object.object_id}/properties/password",
              'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object-property"',
              'method' => 'GET' }
          ],
          'extensions' => { }
        },
        'addresses' => {
          'memberType' => 'collection',
          'size' => 1,
          'links' => [
            { 'rel' => 'urn:org.restfulobjects:rels/details;collection="addresses"',
              'href' => "http://localhost/objects/ObjectTest/#{object.object_id}/collections/addresses",
              'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object-collection"',
              'method' => 'GET' }
          ],
          'extensions' => { }
        },
        'hash_password' => {
          'memberType' => 'action',
          'links' => [
            { 'rel' => 'urn:org.restfulobjects:rels/details;action="hash_password"',
              'href' => "http://localhost/objects/ObjectTest/#{object.object_id}/actions/hash_password",
              'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object-action"',
              'method' => 'GET' }
          ],
          'extensions' => { }
        }
      },
      'links' => [
        { 'rel' => 'self',
          'href' => "http://localhost/objects/ObjectTest/#{object.object_id}",
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/object"',
          'method' => 'GET' },
        { 'rel' => 'describedby',
          'href' => "http://localhost/domain-types/ObjectTest",
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/domain-type"',
          'method' => 'GET' }
      ],
      'extensions' => wildcard_matcher
    }

    CONTENT_TYPE = 'application/json;profile="urn:org.restfulobjects:repr-types/object";x-ro-domain-type="ObjectTest"'
    expect(last_response.content_type).to eq CONTENT_TYPE
    expect(last_response.body).to         match_json_expression expected
  end
end

