require 'spec_helper'

describe 'Queue::Board' do
  include Smash::CloudPowers::Synapse::Queue

  before(:all) do
    Dotenv.load("#{project_root}/.test.env")
    @test_name = 'testQueue'
    @test_queues = []
    @valid_message = { 'foo' => 'bar' }
    @invalid_message = 'foo:bar'
    @board = Smash::CloudPowers::Queue::Board.create!(@test_name)
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
    start = @board.message_count
    @board.send_message(@valid_message)
    sleep 5
    final = @board.message_count
    expect(start).to be < final
  end

  it 'should be able to get the count in its queue' do
    expect(@board.message_count).to be >= 0
  end

  after(:all) do
    @board.destroy!
  end
end
