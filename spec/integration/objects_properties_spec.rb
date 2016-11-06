require_relative '../spec_helper'

describe '=> /objects/:type/:instance_id/properties/' do
  describe 'simple properties,' do
    it 'updates simple property' do
      class TestObject
        include RestfulObjects::Object
        property :name, :string
      end
      test_object = TestObject.new

      put "/objects/TestObject/#{test_object.ro_instance_id}", { 'name' => { 'value' => 'john smith' } }.to_json

      expect(last_response.body).to match_json_expression({ members: { name: { value: 'john smith' } } })
    end

    it 'updates multiple properties' do
      class TestObject
        include RestfulObjects::Object
        property :name,   :string
        property :age,    :int
        property :weight, :decimal
      end
      test_object = TestObject.new

      json =  { 'name' => { 'value' => 'john smith' }, 'age' => { 'value' => '29' }, 'weight' => { 'value' => '71.5' } }.to_json

      put "/objects/TestObject/#{test_object.ro_instance_id}", json

      expect(last_response.body).to match_json_expression({
        members: {
          name:   { value: 'john smith' },
          age:    { value: 29 },
          weight: { value: 71.5 }
        }
      })
    end
  end

  describe 'reference properties,' do
    before(:each) do
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

      get "/objects/PropertyRefTest/#{@object.ro_instance_id}/properties/reference"

      expect(last_response.body).to match_json_expression(
        { reference:
          { value:
            { rel:    'urn:org.restfulobjects:rels/value;property="reference"',
              href:   "http://localhost/objects/ReferenceType/#{@referenced.object_id}",
              type:   'application/json;profile="urn:org.restfulobjects:repr-types/object"',
              method: 'GET',
              title:  @referenced.ro_title
            }
          }
        }
      )
    end

    it 'lists choices' do
      choices = [ReferenceType.new, ReferenceType.new, ReferenceType.new]
      @object.define_singleton_method(:reference_choices) { choices }

      get "/objects/PropertyRefTest/#{@object.ro_instance_id}/properties/reference"

      expect(last_response.body).to match_json_expression(
        { reference:
          { value: nil,
            choices: [
              { rel:    'urn:org.restfulobjects:rels/value;property="reference"',
                href:   "http://localhost/objects/ReferenceType/#{choices[0].object_id}",
                type:   'application/json;profile="urn:org.restfulobjects:repr-types/object"',
                method: 'GET',
                title:  choices[0].ro_title },
              { rel:    'urn:org.restfulobjects:rels/value;property="reference"',
                href:   "http://localhost/objects/ReferenceType/#{choices[1].object_id}",
                type:   'application/json;profile="urn:org.restfulobjects:repr-types/object"',
                method: 'GET',
                title:  choices[1].ro_title },
              { rel:    'urn:org.restfulobjects:rels/value;property="reference"',
                href:   "http://localhost/objects/ReferenceType/#{choices[2].object_id}",
                type:   'application/json;profile="urn:org.restfulobjects:repr-types/object"',
                method: 'GET',
                title:  choices[2].ro_title }
            ]
          }
        }
      )
    end

    it 'puts representation' do
      json = { 'value' => { 'href' => @referenced.ro_absolute_url } }.to_json
      expect(@object.ro_put_property_and_get_response(:reference, json).last).to match_json_expression(
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
