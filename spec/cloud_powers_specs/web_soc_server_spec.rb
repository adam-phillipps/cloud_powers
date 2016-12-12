require 'spec_helper'

describe 'Synapse::WebSoc::Server' do
  include Smash::CloudPowers::Synapse::WebSoc::SocClient
  include Smash::CloudPowers::Synapse::WebSoc::SocServer

  before(:all) do
    @default_config = {host:'127.0.0.1',port:'9090'}
  end

  it '#create_websoc_server() should be not nil' do
    websocket_server = create_websoc_server(@default_config)
    expect(websocket_server).to be_truthy
  end

end
