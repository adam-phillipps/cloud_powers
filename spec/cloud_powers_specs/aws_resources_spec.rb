require 'spec_helper'

describe 'AwsResources' do
  include Smash::CloudPowers::AwsResources
  include Smash::CloudPowers::Synapse::Queue
  include Smash::CloudPowers::Zenv

  before(:all) do
    Dotenv.load("#{project_root}/.test.env")
    @test_name = 'test'
    sqs(Smash::CloudPowers::AwsStubs.queue_stub(name: @test_name))
  end

  it '#ec2() should be able to create an EC2 object' do
    expect(ec2).to be_kind_of Aws::EC2::Client
  end

  it '#image() should be able to get an image from a given name' do
    expect(image('*')).to be_kind_of Aws::EC2::Types::Image
  end

  it '#kinesis() should be able to create a Kinesis object' do
    expect(kinesis).to be_kind_of Aws::Kinesis::Client
  end

  it '#queue_poller() should be able to create a queue poller instance' do
    expect(queue_poller(url: best_guess_address(@test_name), client: sqs))
  end

  it '#s3() should be able to create a S3 object' do
    expect(s3).to be_kind_of Aws::S3::Client
  end

  it '#sns() should be able to create a SNS object' do
    expect(sns).to be_kind_of Aws::SNS::Client
  end

  it '#sqs() should be able to create a SQS object' do
    expect(sqs).to be_kind_of Aws::SQS::Client
  end
end
