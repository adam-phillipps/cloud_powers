require 'spec_helper'
require 'cloud_powers/stubs/aws_stubs'

describe 'Queue::Board' do
  include Smash::CloudPowers::Synapse::Queue

  before(:all) do
    Dotenv.load("#{project_root}/.test.env")
    @temp_name = 'test'
    @actual_name = board_name(@temp_name)
    @test_queues = []
    @valid_message = { 'foo' => 'bar' }
    @invalid_message = 'foo:bar'
    sqs(Smash::CloudPowers::AwsStubs.queue_stub(name: @temp_name))
  end

  before(:each) do
    build_board(name: @temp_name, client: @sqs).link
  end

  context '#pluck_message' do
    before(:each) do
      test_board.send_message(@valid_message)
    end

    it 'should be able to retrieve a message from a given queue' do
      message = test_board.pluck_message
      expect(message).to eql @valid_message
    end
  end

  context '#send_message' do
    it 'should be able to send a message to a given queue' do
      resp = test_board.send_message(@valid_message)
      expect(resp).to respond_to :md5_of_message_body
    end
  end

  it 'should be able to get the count in its queue' do
    expect(test_board.message_count).to be >= 0
  end

  after(:all) do
    @test_queues.map(&:destroy!)
  end
end
