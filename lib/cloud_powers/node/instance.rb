require 'cloud_powers/node'
require 'cloud_powers/resource'

module Smash
  module CloudPowers
    module Node
      class Instance < Smash::CloudPowers::Resource
        include Smash::CloudPowers::Node

        # The name of the Aws::EC2 instance
        attr_accessor :name
        # An Aws::EC2::Client. See <tt>Smash::CloudPowers::AwsResources#ec2()</tt>
        attr_accessor :ec2

        def initialize(name:, client: ec2, **config)
          super(name: name)
          @ec2 = client
        end

        # Uses +Aws::EC2#run_instances()+ to create nodes (Neurons or Cerebrums), at
        # a rate of 0..(n <= 100) at a time, until the required number of instances
        # has been started.  The #instance_config() method is used to create instance
        # configuration for the #run_instances method by using the opts hash that was
        # provided as a parameter.
        #
        # Parameters
        # * opts +Hash+ (optional)
        #   an optional instance configuration hash can be passed, which will override
        #   the values in the default configuration returned by #instance_config()
        def create_resource
          # response = ec2.run_instances(
          #   node_config(max_count: 1, self.to_h)
          # ).instances.first

          instance_attr_accessor response
          # id = @response[:instance_id]
          begin
            ec2.wait_until(:instance_running, instance_ids: [id]) do
              logger.info "waiting for #{ids.count} Neurons to start..."
            end
          rescue Aws::Waiters::Errors::WaiterFailed => e
            # TODO: retry stuff
            # redo unless (count += 1 <=3 )
          end

          yield self if block_given?
          self
        end
      end
    end
  end
end
