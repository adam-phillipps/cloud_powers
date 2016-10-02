require 'spec_helper'

describe 'Broadcast' do
  include Smash::CloudPowers::Synapse::Broadcast
  include Smash::CloudPowers::Zenv

  before(:all) do
    Dotenv.load("#{project_root}/.test.env")
    @channel_name = 'testChannel'
    @channel = create_channel!(@channel_name)
    @channels = [@channel]
  end

  context 'Sending messages' do
    it 'should be able to broadcast a blank message on a communication channel' do
      resp = send_broadcast(topic_arn: @channels.first.arn)
      expect(resp.message_id).not_to be_empty
    end

    it 'should be able to broadcast a filled message on a communication channel' do
      resp = send_broadcast(topic_arn: @channels.first.arn, message: { "foo":"bar" }.to_json)
      expect(resp.message_id).not_to be_empty # lame test
    end
  end

  it 'should be able to create a channel to broadcast through' do
    name = "testChannel#{rand(10000)}"
    resp = create_channel!(name)
    @channels << resp
    expect(resp.arn).to be_truthy
    expect(resp.name).to be_eql(name)
  end

  after(:all) do
    @channels.each do |channel|
      delete_channel!(channel)
    end
  end
end