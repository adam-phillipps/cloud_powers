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

  let(:resource_config) { { job: 'demo', b: [] } }
  let(:new_config) { { job: 'demo', c: [] } }

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

    class Smash::B < Smash::CloudPowers::Resource
      include Smash::BrainFunc::ContextCapable
      def initialize(**config); end
      def create_resource; end
      def saved?
        true
      end
    end

    class Smash::C
      def initialize(**config); end
      def saved?
        true
      end
    end
  end

  context('create_context') do
    let(:test_class) { Smash::A.new }
    let(:enabled_with_modules) { test_class.create_context hash_config; test_class }
    let(:enabled_with_resources) { test_class.create_context resource_config; test_class }
    let(:not_enabled) { test_class.create_context new_config; test_class }

    it 'should give a context to a class' do
      expect(enabled_with_modules).to respond_to(:context)
    end

    it 'should create all resources in the description' do
      expect(enabled_with_modules).to respond_to(:backlog_board)
      expect(enabled_with_modules).to respond_to(:sned_board)
      expect(enabled_with_modules).to respond_to(:status_stream)
    end

    it 'should create an instance of an object using the CloudPowers or BrainFunc CRUD interfaces' do
      expect(enabled_with_modules).to respond_to(:context)
    end

    it 'should create an instance of an object using <tt>Smash::CloudPowers::Resource</tt>s' do
      expect(enabled_with_resources).to respond_to(:b)
      expect(enabled_with_resources.b).to respond_to(:saved?)
    end

    it 'should create an instance of an object using .new()' do
      expect(not_enabled).to respond_to(:c)
    end
  end
end
