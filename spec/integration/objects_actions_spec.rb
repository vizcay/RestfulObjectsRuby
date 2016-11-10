require_relative '../spec_helper'

describe '=> /objects/:type/:instance_id/actions/' do
  before(:all) do
    RestfulObjects::DomainModel.current.reset
  end
end
