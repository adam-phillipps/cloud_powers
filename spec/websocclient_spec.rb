require 'spec_helper'

describe 'Synapse::WebSocClient' do

  include Smash::CloudPowers::Synapse::WebSocServer
  include Smash::CloudPowers::Synapse::WebSocClient

  before(:all) do
    @default_config = {host:'127.0.0.1',port:'9090'}
  end

  it '#create_websoc_server() should be not nil' do
    @websocket_server = create_websoc_server(@default_config)
    expect(@websocket_server).to be_truthy
  end


  it '#create_websoc_client() should be not nil' do
    @clients = {}
    @default_client_configs = {name:'default_client',host:'127.0.0.1',port:'9090'}
    create_websoc_client(@default_client_configs)

    @default_client = @clients[@default_client_configs[:name]]
    expect(@default_client).to be_truthy

  end



end
