require_relative '../spec_helper'

describe '=> /domain-types/:type/collections/' do
  before(:all) do
    RestfulObjects::DomainModel.current.reset
  end
end
