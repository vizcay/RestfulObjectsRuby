# encoding: utf-8
require_relative '../spec_helper'

describe '/domain-types/:type/actions/:action' do
  before(:all) do
    RestfulObjects::DomainModel.current.reset
  end

  it 'should generate an action description representation' do
    class ActionTest
      include RestfulObjects::Object
      action :do_something, :int, {}, friendly_name: 'do something!', description: 'description of something'
    end

    expected = {
      'id' => 'do_something',
      'friendlyName' => 'do something!',
      'description' => 'description of something',
      'hasParams' => false,
      'memberOrder' => :integer,
      'parameters' => {},
      'links' => [
        { 'rel' => 'self',
          'href' => 'http://localhost/domain-types/ActionTest/actions/do_something',
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/action-description"',
          'method' => 'GET' },
        { 'rel' => 'up',
          'href' => 'http://localhost/domain-types/ActionTest',
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/domain-type"',
          'method' => 'GET' },
        { 'rel' => 'urn:org.restfulobjects:rels/return-type',
          'href' => 'http://localhost/domain-types/int',
          'type' => 'application/json;profile="urn:org.restfulobjects:repr-types/domain-type"',
          'method' => 'GET' }
      ]
    }

    get '/domain-types/ActionTest/actions/do_something'

    last_response.body.should match_json_expression expected
  end
end

