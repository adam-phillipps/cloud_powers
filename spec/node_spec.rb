require 'spec_helper'
require_relative './aws_stubs'
describe 'Node' do
  include Smash::CloudPowers::AwsResources
  include Smash::CloudPowers::Helper
  include Smash::CloudPowers::Node
  include Smash::CloudPowers::Zenv

  before(:all) do
    Dotenv.load("#{project_root}/.test.env")
    byebug
    # @r_i = {
    #   stub_responses: {
    #     run_instances: {
    #       instances: [
    #         { instance_id: 'asd-1234', launch_time: Time.now, state: { name: 'running' } },
    #         { instance_id: 'qwe-4323', launch_time: Time.now, state: { name: 'running' } },
    #         { instance_id: 'tee-4322', launch_time: Time.now, state: { name: 'running' } },
    #         { instance_id: 'bbf-6969', launch_time: Time.now, state: { name: 'running' } },
    #         { instance_id: 'lkj-0987', launch_time: Time.now, state: { name: 'running' } },
    #       ]
    #     },
    #     describe_instances: {
    #       reservations: [{ instances: [{ instance_id: 'asd-1234', state: { code: 200, name: 'running' } },
    #                         { instance_id: 'qwe-4323', state: { code: 200, name: 'running' } },
    #                         { instance_id: 'tee-4322', state: { code: 200, name: 'running' } },
    #                         { instance_id: 'bbf-6969', state: { code: 200, name: 'running' } },
    #                         { instance_id: 'lkj-0987', state: { code: 200, name: 'running' } }]}]},
    #     describe_images: {
    #       images: [
    #         { image_id: 'asdf', state: 'available' },
    #         { image_id: 'fdas', state: 'available' },
    #         { image_id: 'fdadg', state: 'available' },
    #         { image_id: 'aswrewdf', state: 'available' },
    #         { image_id: 'fsn', state: 'available' },
    #       ]
    #     }
    #   }
    # }
  end

  context('#spin_up_neurons') do
    let(:config) { SPIN_UP_NEURONS.merge(max_count: 5) }

    it 'should be able to start n number of nodes' do
      expect(spin_up_neurons(ec2: config).count).to eql(5)
    end
  end

  it '#node_config should have a valid default Hash for starting nodes' do
    expect(node_config).to be_kind_of(Hash)
  end
end
