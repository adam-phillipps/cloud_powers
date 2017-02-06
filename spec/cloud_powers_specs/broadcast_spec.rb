require 'spec_helper'

describe 'Broadcast' do
  extend Smash::CloudPowers::AwsStubs
  include Smash::CloudPowers::Synapse::Broadcast
  include Smash::CloudPowers::Zenv

  before(:all) do
    Dotenv.load("#{project_root}/.test.env")
    @channel_name = 'test'
    sns(Smash::CloudPowers::AwsStubs.broadcast_stub)
    create_channel(@channel_name)
    @channels = [test_channel]
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
    @channels << create_channel(@channel_name)
    expect(test_channel.remote_id).to be_truthy
    expect(test_channel.name).to be_eql(@channel_name)
  end

  after(:all) do
    @channels.each do |channel|
      delete_channel!(channel)
    end
  end
end
