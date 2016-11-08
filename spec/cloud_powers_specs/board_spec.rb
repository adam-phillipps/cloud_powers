require 'spec_helper'
require 'cloud_powers/stubs/aws_stubs'

describe 'Queue::Board' do
  include Smash::CloudPowers::Synapse::Queue

  before(:all) do
    Dotenv.load("#{project_root}/.test.env")
    @temp_name = 'testQueue'
    @test_queues = []
    @valid_message = { 'foo' => 'bar' }
    @invalid_message = 'foo:bar'
    sqs(Smash::CloudPowers::AwsStubs.queue_stub(name: @temp_name))
    @board = Smash::CloudPowers::Queue::Board.create!(@temp_name, sqs)
    @board.create_queue!
  end

  context 'plucking' do
    before(:each) do
      @board.send_message(@valid_message)
    end

    it 'should be able to retrieve a message from a given queue' do
      message = @board.pluck_message
      expect(message).to eql @valid_message
    end
  end

  it 'should be able to send a message to a given queue' do
    resp = @board.send_message(@valid_message)
    expect(resp).to respond_to :md5_of_message_body
  end

  it 'should be able to get the count in its queue' do
    expect(@board.message_count).to be >= 0
  end

  after(:all) do
    @board.destroy!
  end
end
