# encoding: utf-8
require_relative '../spec_helper'

describe RestfulObjects::Object do
  before :all do
    RestfulObjects::DomainModel.current.reset

    class Address
      include RestfulObjects::Object

      property :street, :string
      property :number, :int
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
  end

  before(:each) do
    @object = ObjectTest.new
  end

  it 'module should add class macros functionality' do
    @object.class.respond_to?(:property).should   be_true
    @object.class.respond_to?(:action).should     be_true
    @object.class.respond_to?(:collection).should be_true
  end

  it 'should add the type information to the model' do
    model.types.include?('ObjectTest').should be_true

    domain_type = model.types['ObjectTest']

    domain_type.properties.include?('id').should be_true
    domain_type.properties['id'].return_type.should eq(:int)
    domain_type.properties['id'].read_only.should be_true
    domain_type.properties['id'].max_length.should be_nil

    domain_type.properties.include?('password').should be_true
    domain_type.properties['password'].return_type.should eq(:string)
    domain_type.properties['password'].read_only.should be_false
    domain_type.properties['password'].max_length.should eq(10)

    domain_type.actions.include?('hash_password').should be_true
    domain_type.actions['hash_password'].parameters.count.should eq(0)
    domain_type.actions['hash_password'].result_type.should eq(:string)
  end

  it 'should generate metadata in extensions' do
    @object.rs_type.plural_name = 'Test Objects'
    @object.rs_type.friendly_name = 'Test Object Friendly'
    @object.rs_type.description = 'An object to test'

    expected = {
      'instanceId' => @object.object_id.to_s,
      'extensions' => {
        'domainType' => 'ObjectTest',
        'pluralName' => 'Test Objects',
        'friendlyName' => 'Test Object Friendly',
        'description' => 'An object to test',
        'isService' => false
      }.strict!
    }

    get "/objects/ObjectTest/#{@object.object_id}"

    last_response.body.should match_json_expression expected
  end

  it 'should call initialize on object' do
    class InitializedObject
      include RestfulObjects::Object
      attr_reader :init_called
      def initialize
        super
        @init_called = true
        @title = 'A title'
      end
    end
    obj = InitializedObject.new
    obj.init_called.should be_true
    obj.title.should eq 'A title'
  end

  it 'should send on_after_create callback when object is created' do
    class CreatedObject
      include RestfulObjects::Object
      attr_reader :called
      def on_after_create
        @called = true
      end
    end

    CreatedObject.new.called.should be_true
  end

  it 'should send on_after_update callback when object property is updated or deleted' do
    class UpdatableObject
      include RestfulObjects::Object
      attr_accessor :prop_updated
      property :data, :string
      def on_after_update
        @prop_updated = true
      end
    end

    obj = UpdatableObject.new

    obj.prop_updated.should_not be_true

    put "/objects/UpdatableObject/#{obj.object_id}/properties/data", {}, { input: { 'value' => 'irrelevant' }.to_json }

    obj.prop_updated.should be_true

    obj.prop_updated = false

    delete "/objects/UpdatableObject/#{obj.object_id}/properties/data"

    obj.prop_updated.should be_true
  end

  it 'should send on_after_delete callback when object is deleted' do
    class TestDeleted
      include RestfulObjects::Object
      attr_reader :destroyed
      def on_after_delete
        @destroyed = true
      end
    end

    obj = TestDeleted.new

    obj.ro_deleted?.should_not be_true
    obj.destroyed.should_not be_true

    delete "/objects/DeletedObject/#{obj.object_id}"

    obj.ro_deleted?.should be_true
    obj.destroyed.should be_true
  end
end

