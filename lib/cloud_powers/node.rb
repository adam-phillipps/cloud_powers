require_relative 'auth'
require_relative 'helper'
require_relative 'self_awareness'
require_relative 'zenv'

module Smash
  module CloudPowers
    module Node
      include Smash::CloudPowers::Auth
      include Smash::CloudPowers::Helper
      include Smash::CloudPowers::SelfAwareness
      include Smash::CloudPowers::Zenv

      # These are sensible defaults that can be overriden by providing a Hash as a param.
      #
      # Parameters
      # * opts +Hash+ (optional)
      #   the opts Hash should have values that should be used instead of the default
      #   configuration.
      def node_config(opts = {})
        {
          dry_run:                                zfind(:testing) || false,
          image_id:                               image('crawlbotprod').image_id, # image(:neuron).image_id
          instance_type:                          't2.nano',
          min_count:                              opts[:max_count] || 1, # 2 ways to override
          max_count:                              1,
          key_name:                               'crawlBot',
          security_groups:                        ['webCrawler'],
          security_group_ids:                     ['sg-940edcf2'],
          placement:                              { availability_zone: 'us-west-2c' },
          disable_api_termination:                'false',
          instance_initiated_shutdown_behavior:   'terminate'
        }.merge(opts)
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
      def spin_up_neurons(opts = {})
        ids = nil
        begin
          response = ec2.run_instances(node_config(opts))
          ids = response.instances.map(&:instance_id)

          begin
            count = 0
            ec2.wait_until(:instance_running, instance_ids: ids) do
              # !    Pretty important.  probably a 2.  it could take a day to get
              #      it right and it could take an hour or so to write specs
              # !
              # !TODO: deal with borked instances.  Aws throws errors for failed
              # instances.  We should:
              #   1. gracefully deal with errors that could break
              #      out of this waiter
              #   2. gather failed ids and try to get some info about if these
              #      failed instances are going down (terminating) or they're good
              #      but they're failing for some other reason e.g. we didn't
              #      set the timeout on the waiter for long enough for a windows
              #      instance or something like that.
              #   3. deal with #2 appropriately and continue.  It would be nice
              #      and clean to just invoke this method again, for
              #      +failed_ids+ number of new instances and re-wait with appropriate
              #      waiter configuration or something like that!
              # ODOT!
              logger.info "waiting for #{ids.count} Neurons to start..."
            end
          rescue Aws::Waiters::Errors::WaiterFailed => e
            redo unless (count += 1 <=3 )
          end

          # tag(ids, { key: 'task', value: to_camel(self.class.to_s) })
        rescue Aws::EC2::Errors::DryRunOperation
          ids = (1..(opts[:max_count] || 0)).to_a.map { |n| n.to_s }
          logger.info "waiting for #{ids.count} Neurons to start..."
        end

        ids
      end
    end
  end
end
