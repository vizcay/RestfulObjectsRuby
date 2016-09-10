# encoding: utf-8
require_relative '../spec_helper'

describe 'DomainObject properties' do
  before(:all) do
    RestfulObjects::DomainModel.current.reset
  end

  it 'should generate a property description representation' do
    class PropertyTest
      include RestfulObjects::Object
      property :name, :string, friendly_name: 'a friendly name', description: 'name description'
    end

    expected = {
      'id' => 'name',
      'friendlyName' => 'a friendly name',
      'description' => 'name description',
      'optional' => true,
      'memberOrder' => :integer,
      'links' => [
        { 'rel' => 'self',
          'href' => 'http://localhost/domain-types/PropertyTest/properties/name',
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/property-description"',
          'method' => 'GET' },
        { 'rel' => 'up',
          'href' => 'http://localhost/domain-types/PropertyTest',
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/domain-type"',
          'method' => 'GET' },
        { 'rel' => 'urn:org.restfulobjects:rels/return-type',
          'href' => 'http://localhost/domain-types/string',
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/domain-type"',
          'method' => 'GET' }
      ]
    }

    get '/domain-types/PropertyTest/properties/name'
    last_response.body.should match_json_expression expected
  end

  describe 'json representation of property reference' do
    before :each do
      class ReferenceType
        include RestfulObjects::Object
      end
      class PropertyRefTest
        include RestfulObjects::Object
        property :reference, { object: ReferenceType }
      end
      @referenced = ReferenceType.new
      @object     = PropertyRefTest.new
    end

    it 'gets representation' do
      @object.reference = @referenced
      expect(@object.ro_get_property_response(:reference).last).to match_json_expression(
        { 'reference' =>
          { 'value' =>
            { 'rel'    => 'urn:org.restfulobjects:rels/value;property="reference"',
              'href'   => "http://localhost/objects/ReferenceType/#{@referenced.object_id}",
              'type'   => 'application/json;profile="urn:org.restfulobjects:repr-types/object"',
              'method' => 'GET',
              'title'  => @referenced.ro_title
            }
          }
        }
      )
    end

    it 'lists choices' do
      choices = [ReferenceType.new, ReferenceType.new, ReferenceType.new]
      @object.define_singleton_method(:reference_choices) { choices }
      expect(@object.ro_get_property_response(:reference).last).to match_json_expression(
        { 'reference' =>
          { 'value' => nil,
            'choices' => [
              { 'rel'    => 'urn:org.restfulobjects:rels/value;property="reference"',
                'href'   => "http://localhost/objects/ReferenceType/#{choices[0].object_id}",
                'type'   => 'application/json;profile="urn:org.restfulobjects:repr-types/object"',
                'method' => 'GET',
                'title'  => choices[0].ro_title },
              { 'rel'    => 'urn:org.restfulobjects:rels/value;property="reference"',
                'href'   => "http://localhost/objects/ReferenceType/#{choices[1].object_id}",
                'type'   => 'application/json;profile="urn:org.restfulobjects:repr-types/object"',
                'method' => 'GET',
                'title'  => choices[1].ro_title },
              { 'rel'    => 'urn:org.restfulobjects:rels/value;property="reference"',
                'href'   => "http://localhost/objects/ReferenceType/#{choices[2].object_id}",
                'type'   => 'application/json;profile="urn:org.restfulobjects:repr-types/object"',
                'method' => 'GET',
                'title'  => choices[2].ro_title }
            ]
          }
        }
      )
    end

    it 'puts representation' do
      json = { 'value' => { 'href' => @referenced.ro_absolute_url } }.to_json
      expect(@object.put_property_as_json(:reference, json).last).to match_json_expression(
        { 'reference' =>
          { 'value' =>
            { 'rel'    => 'urn:org.restfulobjects:rels/value;property="reference"',
              'href'   => "http://localhost/objects/ReferenceType/#{@referenced.object_id}",
              'type'   => 'application/json;profile="urn:org.restfulobjects:repr-types/object"',
              'method' => 'GET',
              'title'  => @referenced.ro_title
            }
          }
        }
      )
      expect(@object.reference).to eq @referenced
    end
  end
end

