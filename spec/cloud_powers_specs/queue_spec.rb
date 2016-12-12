require 'spec_helper'
require 'json'
require 'cloud_powers/stubs/aws_stubs'

describe 'Synapse::Queue' do
  extend Smash::CloudPowers::AwsStubs
  include Smash::CloudPowers::Synapse::Queue
  include Smash::CloudPowers::Zenv

  before(:all) do
    Dotenv.load("#{project_root}/.test.env")
    @test_queues = []
    @valid_message = { 'foo' => 'bar' }
    @invalid_message = 'foo:bar'
  end

  before(:each) do
    @temp_name = "testBoard#{rand(9999)}"
    @stub = Smash::CloudPowers::AwsStubs.queue_stub(name: @temp_name)
    @temp_url = @stub[:stub_responses][:create_queue][:queue_url]
    sqs(@stub)
  end

  it 'should be able to get the count in a given queue' do
    actual = @stub[:stub_responses][:get_queue_attributes][:attributes]['ApproximateNumberOfMessages'].to_f
    board = build_board(name: @temp_name, client: @sqs)
    expect(board.message_count).to eq(actual)
  end

  it 'should be able to return a queue name from the URL' do
    expect(board_name(@temp_url)).to eql(to_snake(@temp_name) + '_board')
  end

  it 'should be able to create an appropriately named Queue::Board' do
    @test_queues << create_board(name: @temp_name, client: @sqs)
    expect(queue_search(to_camel(@temp_name))).not_to be_empty
  end

  it 'should be able to check if a queue exists' do
    @test_queues.each do |queue|
      expect(queue_exists?(queue.name)).to be true
    end
  end

  context 'plucking' do
    before(:each) do
      build_board(name: @temp_name, client: @sqs).send_message(@valid_message)
    end

    it 'should be able to poll without a Queue::Board to assist' do
      message = poll(@temp_name) do |msg|
        msg.body
      end
      expect(message).to eql @valid_message.to_json
    end
  end

  context '#create_queue' do
    it 'sould be able to create a default queue if no type is given' do
      board = build_board(name: @temp_name, client: @sqs)
      expect(board).to be_kind_of Smash::CloudPowers::Synapse::Queue::Board
    end
  end
end
