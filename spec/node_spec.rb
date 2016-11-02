require 'spec_helper'
require_relative '../lib/stubs/aws_stubs'

describe 'Node' do
  include Smash::CloudPowers::AwsStubs
  include Smash::CloudPowers::AwsResources
  include Smash::CloudPowers::Helper
  include Smash::CloudPowers::Node
  include Smash::CloudPowers::Zenv

  before(:all) do
    Dotenv.load("#{project_root}/.test.env")
    @config = Smash::CloudPowers::AwsStubs.node_stub.merge(max_count: 5)
  end

  before(:each) do
    @ec2 = ec2(@config) # ec2 is now stubbed and cached
  end

  context('#spin_up_neurons') do
    it 'should be able to start n number of nodes' do
      expect(spin_up_neurons.count).to eql(5)
    end
  end

  context('#batch_tags') do
    it 'should be able to add or overwrite tags to resources' do
      ids = ['asd-1234']
      tags = [{ key: 'stack', value: 'production' }]
      expect(create_tags(ids, tags)).not_to be_nil
    end
  end

  it '#node_config should have a valid default Hash for starting nodes' do
    expect(node_config).to be_kind_of(Hash)
  end
end
