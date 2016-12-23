require 'cloud_powers/auth'
require 'cloud_powers/helpers'
require 'cloud_powers/zenv'
require 'cloud_powers/node/instance'

module Smash
  module CloudPowers
    module Node
      include Smash::CloudPowers::Auth
      include Smash::CloudPowers::Helpers
      include Smash::CloudPowers::Zenv

      # This method adds certain tags to an array of resource ids.
      #
      # Parameters
      # * ids +Array+|+String+ - an Array or a single instance id, as an Array
      #   of Strings or a single String
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
      def batch_tag(ids, tags, client: ec2)
        tags_opts = { resources: ids, tags: tags }
        ec2.create_tags(tags_opts)
        logger.info "tags for #{ids} created"
      end

      def build_node(name:, client: ec2, **config)
        resp = Smash::CloudPowers::Node::Instance.build(name: name, client: ec2, **config)
        i_var_name = "#{name}_node"
        instance_attr_accessor i_var_name
        instance_variable_set(to_i_var(i_var_name), resp)
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
      def create_node(name:, client: ec2, **config)
        resp = Smash::CloudPowers::Node::Instance.create!(name: name, client: ec2, **config)
        i_var_name = "#{name}_node"
        instance_attr_accessor i_var_name
        instance_variable_set(to_i_var(i_var_name), resp)
      end

      # Uses +Aws::EC2#run_instances()+ to create nodes (Neurons or Cerebrums),
      # at a rate of 0..(n <= 100) at a time, until the required number of
      # instances has been started.  The #instance_config() method is used to
      # create instance configuration for the #run_instances method by using
      # the opts hash that was provided as a parameter.
      #
      # Parameters
      # * opts +Hash+ (optional) - an optional instance configuration hash can
      #   be passed, which will override the values in the default configuration
      #   returned by <tt>#instance_config()</tt>
      #
      # Returns
      # +Array+ of responses from
      def create_nodes(name:, client: ec2, **config)
        resp = ec2.run_instances(node_config(config)).instances
        i_var_name = "#{name}_nodes"
        instance_attr_accessor i_var_name
        instance_variable_set(to_i_var(i_var_name), resp)
      end

      # These are sensible defaults that can be overriden by providing a Hash as a param.
      #
      # Parameters
      # * opts +Hash+ (optional)
      #   the opts Hash should have values that should be used instead of the default
      #   configuration.
      def node_config(**config)
        {
          dry_run:                                zfind(:testing) || false,
          image_id:                               image(zfind(:node_image)).image_id, # image(:neuron).image_id
          instance_type:                          't2.nano',
          min_count:                              config[:max_count] || 0,
          max_count:                              0,
          key_name:                               'crawlBot',
          security_groups:                        ['webCrawler'],
          security_group_ids:                     ['sg-940edcf2'],
          placement:                              { availability_zone: 'us-west-2c' },
          disable_api_termination:                'false',
          instance_initiated_shutdown_behavior:   'terminate'
        }.merge(config)
      end
    end
  end
end
