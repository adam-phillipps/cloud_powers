require 'spec_helper'

describe 'Smash::BrainFunc::Context' do
  include Smash::CloudPowers::AwsResources
  include Smash::BrainFunc::ContextCapable
  include Smash::CloudPowers::Helpers
  include Smash::CloudPowers::Zenv

  before(:all) do
    Dotenv.load("#{project_root}/.test.env")
  end

  before(:each) do
    ec2(Smash::CloudPowers::AwsStubs.node_stub.merge(max_count: 5))
    kinesis(
      Smash::CloudPowers::AwsStubs.pipe_stub(
        name: 'testStream', sequence_number: '1234'
      )
    )
    sns(Smash::CloudPowers::AwsStubs.broadcast_stub)
    sqs(Smash::CloudPowers::AwsStubs.queue_stub(name: @temp_name))
  end

  let(:hash_config) do
    {
      job: 'demo',
      board: [{ name: 'backlog', client: sqs }, { name: 'sned', client: sqs }],
      pipe: [{ name: 'status', client: kinesis }]
    }
  end

  module Smash
    class A
      include Smash::CloudPowers
      include Smash::BrainFunc::ContextCapable
      def initialize
        ec2(Smash::CloudPowers::AwsStubs.node_stub.merge(max_count: 5))
        kinesis(
          Smash::CloudPowers::AwsStubs.pipe_stub(
            name: 'testStream', sequence_number: '1234'
          )
        )
        sns(Smash::CloudPowers::AwsStubs.broadcast_stub)
        sqs(Smash::CloudPowers::AwsStubs.queue_stub(name: @temp_name))
      end
    end
  end

  context('create_context') do
    let(:test_class) { Smash::A.new }
    let(:context_enabled_class) { test_class.create_context hash_config; test_class }

    it 'should give a context to a class' do
      expect(context_enabled_class).to respond_to(:context)
    end

    it 'should create all resources in the description' do
      expect(context_enabled_class).to respond_to(:backlog_board)
      expect(context_enabled_class).to respond_to(:sned_board)
      expect(context_enabled_class).to respond_to(:status_stream)
    end
  end
end
