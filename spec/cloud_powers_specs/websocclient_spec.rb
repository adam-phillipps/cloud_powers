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
    @default_client_configs = {name:'default_client',host:'127.0.0.1',port:'9090',
                               on_open: Proc.new do
                                 expect(@default_client).to be_truthy
                               end
    }
    create_websoc_client(@default_client_configs)
  end

end
