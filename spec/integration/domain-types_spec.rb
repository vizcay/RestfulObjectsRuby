require_relative '../spec_helper'

describe '=> /domain-types' do
  before(:all) do
    RestfulObjects::DomainModel.current.reset

    class DomainObject
      include RestfulObjects::Object
    end
  end

  describe 'GET /domain-types' do
    it 'generates response with a domain types in value arrray' do
      get '/domain-types'
      last_response.body.should match_json_expression(
        { value:
          [ { rel: 'urn:org.restfulobjects:rels/domain-type',
            href: "http://localhost/domain-types/DomainObject",
            type: 'application/json;profile="urn:org.restfulobjects:repr-types/domain-type"',
            method: 'GET' } ]
        })
    end

    it 'generates response links to homepage & sellf' do
      get '/domain-types'
      last_response.body.should match_json_expression(
        { links: [
            { rel: 'self',
              href: 'http://localhost/domain-types',
              type: 'application/json;profile="urn:org.restfulobjects:repr-types/type-list"',
              method: 'GET' },
            { rel: 'up',
              href: 'http://localhost/',
              type: 'application/json;profile="urn:org.restfulobjects:repr-types/homepage"',
              method: 'GET' } ]
        })
    end
  end
end
