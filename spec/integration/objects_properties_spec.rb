require_relative '../spec_helper'

describe '=> /objects/:type/:instance_id/properties/' do
  describe '#ro_put_multiple_properties_and_get_response' do
    it 'updates simple property' do
      class TestObject
        include RestfulObjects::Object
        property :name, :string
      end
      test_object = TestObject.new
      response    = test_object.ro_put_multiple_properties_and_get_response({ 'name' => { 'value' => 'john smith' } }.to_json)
      expect(response.body).to match_json_expression({ 'members' => { 'name' => { 'value' => 'john smith' } } })
    end

    it 'updates multiple properties' do
      class TestObject
        include RestfulObjects::Object
        property :name,   :string
        property :age,    :int
        property :weight, :decimal
      end
      test_object = TestObject.new
      response    = test_object.ro_put_multiple_properties_and_get_response({ 'name'   => { 'value' => 'john smith' },
                                                                              'age'    => { 'value' => '29' },
                                                                              'weight' => { 'value' => '71.5' } }.to_json)
      expect(response.body).to match_json_expression({ 'members' => {
                                                         'name'   => { 'value' => 'john smith' },
                                                         'age'    => { 'value' => 29 },
                                                         'weight' => { 'value' => 71.5 } }
                                                     })
    end
  end
end
