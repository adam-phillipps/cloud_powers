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
          min_count:                              opts[:max_count] || 0,
          max_count:                              0,
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
      def spin_up_neurons(opts = {}, tags = [])
        should_wait = opts.delete(:wait) || true
        ids = nil
        begin

          response = ec2.run_instances(node_config(opts))
          ids = response.instances.map(&:instance_id)

          if should_wait
            count = 0
            begin
              ec2.wait_until(:instance_running, instance_ids: ids) do
                logger.info "waiting for #{ids.count} Neurons to start..."
              end
            rescue Aws::Waiters::Errors::WaiterFailed => e
              # TODO: deal with failed instances
              # redo unless (count += 1 <=3 )
            end
          end

          batch_tag(ids, tags) unless tags.empty?
          ids

        rescue Aws::EC2::Errors::DryRunOperation
          ids = (1..(opts[:max_count] || 0)).to_a.map { |n| n.to_s }
          logger.info "waiting for #{ids.count} Neurons to start..."
        end

        ids
      end

      # This method adds certain tags to an array of resource ids.
      #
      # Parameters
      # * ids +Array+|+String+ - an Array or a single instance id, as an Array of Strings or a single String
      # * tags +Array+ - an Array of key, value hash
      #
      # Returns
      # * Returns an empty response.
      #
      # Examples
      #   create_tag('ami-2342354', tags: { key: "stack", value: "production"})
      #   or
      #   create_tag(['ami-2432342'], tags: [{ key: 'stack', value: 'production' }])
      #   or any permutation of those

      def batch_tag(ids, tags)
        tags_opts = { resources: ids, tags: tags }
        ec2.create_tags(tags_opts)
        logger.info "tags for #{ids} created"
      end

    end
  end
end
