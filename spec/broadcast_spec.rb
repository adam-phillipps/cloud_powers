require 'spec_helper'

describe 'Broadcast' do
  include Smash::CloudPowers::Synapse::Broadcast

  it 'should be able to create a channel to broadcast through' do
    fail
  end

  it 'should be able to broadcast a message on a communication channel' do
    fail
  end

  it 'should be able to listen for a message when there is nothing to listen to' do
    fail
  end

  it 'should be able to receive a message, after it starts listening' do
    fail
  end

  after(:all) do
    channels.each do |channel|
      channel.destroy!
    end
  end
end
