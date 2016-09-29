require 'spec_helper'
require 'json'

describe 'Synapse::Queue' do
  include Smash::CloudPowers::Synapse::Queue
  include Smash::CloudPowers::Zenv

  before(:all) do
    Dotenv.load("#{project_root}/.test.env")
    @test_name = 'testQueue'
    @test_queues = []
    @valid_message = { 'foo' => 'bar' }
    @invalid_message = 'foo:bar'
    @test_queue = create_queue!(@test_name)
    @test_queues << @test_queue
  end

  it 'should be able to get the count in a given queue' do
    board = build_queue(@test_name)
    expect(get_queue_message_count(board.address)).to be >= 0
  end

  it 'should be able to return a queue name from the URL' do
    expect(board_name(build_queue(@test_name).address)).to eql(to_camel(@test_name))
  end

  it 'should be able to create a queue' do
    temp_name = "testBoard#{rand(9999)}"
    @test_queues << create_queue!(temp_name)
    expect(queue_search(to_camel(temp_name))).not_to be_empty
  end

  it 'should be able to check if a queue exists' do
    @test_queues.each do |queue|
      expect(queue_exists?(queue.name)).to be true
    end
  end

  context 'plucking' do
    before(:each) do
      build_queue(@test_name).send_message(@valid_message)
    end

    it 'should be able to poll without a Queue::Board to assist' do
      message = poll(@test_name) do |msg|
        msg.body
      end
      expect(message).to eql @valid_message.to_json
    end
  end

  after(:all) do
    @test_queues.each { |queue| queue.destroy! }
  end
end
