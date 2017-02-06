require 'spec_helper'

describe 'Node' do
  include Smash::CloudPowers::AwsStubs
  include Smash::CloudPowers::AwsResources
  include Smash::CloudPowers::Helpers
  include Smash::CloudPowers::Node
  include Smash::CloudPowers::Zenv

  before(:all) do
    Dotenv.load("#{project_root}/.test.env")
    @config = Smash::CloudPowers::AwsStubs.node_stub.merge(max_count: 5)
    @name = 'test'
  end

  before(:each) do
    @ec2 = ec2(@config) # ec2 is now stubbed and cached
  end

  context '#create_nodes' do
    let(:default_config) { { name: @name, client: ec2, max_count: 5 } }

    it 'should be able to start n number of nodes' do
      expect(create_nodes(default_config).count).to eql(5)
    end
  end

  context '#batch_tag' do
    it 'should be able to add or overwrite tags to resources' do
      ids = @config[:stub_responses][:describe_instances][:reservations].first[:instances].map { |i| i[:instance_id] }
      tags = Smash::CloudPowers::AwsStubs.instance_tags_stub[:tags]
      expect(batch_tag(ids, tags)).not_to be_nil
    end
  end

  it '#node_config should have a valid default Hash for starting nodes' do
    expect(node_config).to be_kind_of(Hash)
  end
end
