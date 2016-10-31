require 'spec_helper'

describe 'Synapse::WebSocClient' do
  include Smash::CloudPowers::Synapse::WebSocServer
  include Smash::CloudPowers::Synapse::WebSocClient

  let(:default_config) { { host: '127.0.0.1', port: '9090' } }
  let(:test_client_configs) do
    {
      name: 'test_client', host: '127.0.0.1', port: '9090',
      on_open: Proc.new do
        expect(@test_client).to be_truthy
      end
    }
  end

  it '#create_websoc_server() should be not nil' do
    @websocket_server = create_websoc_server(default_config)
    expect(@websocket_server).to be_truthy
  end

  it '#create_websoc_client() should be not nil' do
    create_websoc_client(test_client_configs)
    sleep 1 # waiting for the other thread to catch up
    expect(@test_client).to be_truthy
  end
end
