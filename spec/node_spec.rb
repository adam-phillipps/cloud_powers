require 'spec_helper'

describe 'Node' do
  include Smash::CloudPowers::AwsResources
  include Smash::CloudPowers::Helper
  include Smash::CloudPowers::Node
  include Smash::CloudPowers::Zenv

  before(:all) do
    Dotenv.load("#{project_root}/.test.env")
  end

  it '#node_config should give a valid default Hash' do
    expect(node_config).to be_kind_of(Hash)
  end

  it '#spin_up_neurons should be able to start n number of nodes' do
    expect(spin_up_neurons(max_count: 3).count).to eql(3)
  end
end
