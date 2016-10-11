require_relative 'auth'
require_relative 'helper'
require_relative 'zenv'

module Smash
  module CloudPowers
    module AwsResources
      include Smash::CloudPowers::Auth
      include Smash::CloudPowers::Helper
      include Smash::CloudPowers::Zenv

      # Get the region from the environment/context or use a default region for AWS API calls.
      # === @returns String
      def region
        zfind(:aws_region) || 'us-west-2'
      end

      # Get or create an EC2 client and cache that client so that a Context is more well tied together
      # === @params: opts [Hash]
      #      * stub_responses: defaulted to false but it can be overriden with the desired responses for local testing
      #      * region: defaulted to use the `#region()` method
      #      * AWS::Credentials object, which will also scour the context and environment for your keys
      # === @returns: AWS::EC2 client
      # === Sample Usage
      #     ```
      #       config = stub_responses: {
      #         run_instances: {
      #           instances: [
      #             { instance_id: 'asd-1234', launch_time: Time.now, state: { name: 'running' }
      #         ] }
      #         describe_instances: {
      #           reservations: [
      #             { instances: [
      #               { instance_id: 'asd-1234', state: { code: 200, name: 'running' } },
      #           ] }] },
      #         describe_images: {
      #           images: [
      #             { image_id: 'asdf', state: 'available' }
      #         ] }
      #       }
      #
      #       ec2(config) # sets and gets an EC2 client
      #
      #       images = ec2.describe_images
      #       images.first[:image_id]
      #       # => 'asdf'
      #     ```
      def ec2(opts = {})
        config = {
          stub_responses: false,
          region: region,
          credentials: Auth.creds
        }
        config = config.merge(opts.select { |k| config.key?(k) })

        @ec2 ||= Aws::EC2::Client.new(config)
      end

      # Get an image using a name and filters functionality from EC2.  The name is required but the filter defaults
      # to search for the tag with the key `aminame` because this is the key that most Nodes will search for, when
      # they gather an AMI to start with.
      # === @params: opts [Hash]
      #      * stub_responses: defaulted to false but it can be overriden with the desired responses for local testing
      #      * region: defaulted to use the `#region()` method
      #      * AWS::Credentials object, which will also scour the context and environment for your keys
      # === @returns: AMI
      def image(name, opts = {})
        config = {
          filters: [{ name: 'tag:aminame', values: [name.to_s] }]
        }
        config = config.merge(opts.select { |k| config.key?(k) })

        ec2(opts).describe_images(config).images.first
      end

      # Get or create an Kinesis client and cache that client so that a Context is more well tied together
      # === @params: opts [Hash]
      #      * stub_responses: defaulted to false but it can be overriden with the desired responses for local testing
      #      * region: defaulted to use the `#region()` method
      #      * AWS::Credentials object, which will also scour the context and environment for your keys
      # === @returns: AWS::Kinesis client
      # === Sample Usage
      #     ```
      #       config = {
      #         stub_responses: {
      #           create_stream: {},
      #             put_record: {
      #               shard_id: opts[:shard_id] || 'idididididididid',
      #               sequence_number: opts[:sequence_number] || Time.now.to_i.to_s
      #             },
      #             describe_stream: {
      #               stream_description: {
      #                 stream_name: opts[:name] || 'somePipe',
      #                 stream_arn:  'arnarnarnarnar',
      #                 stream_status: 'ACTIVE',
      #               }
      #             }
      #           }
      #         }
      #       }
      #
      #       kinesis(config) # sets and gets an Kinesis client
      #
      #       pipe_to('somePipe') { update_body(status: 'waHoo') }
      #       # => sequence_number: '1676151970'
      #     ```
      def kinesis(opts = {})
        config = {
          stub_responses: false,
          region: region,
          credentials: Auth.creds
        }
        config = config.merge(opts.select { |k| config.key?(k) })

        @kinesis ||= Aws::Kinesis::Client.new(config)
      end

      # Get or create an S3 client and cache that client so that a Context is more well tied together
      # === @params: opts [Hash]
      #      * stub_responses: defaulted to false but it can be overriden with the desired responses for local testing
      #      * region: defaulted to use the `#region()` method
      #      * AWS::Credentials object, which will also scour the context and environment for your keys
      # === @returns: AWS::S3 client
      # === Sample Usage
      #     ```
      #       config = {
      #         stub_responses: {
      #
      #         }
      #       }
      #
      #     ```

      def s3(opts = {})
        config = {
          stub_responses: false,
          region: region,
          credentials: Auth.creds
        }
        config = config.merge(opts.select { |k| config.key?(k) })

        @s3 ||= Aws::S3::Client.new(config)
      end

      # Get or create an SNS client and cache that client so that a Context is more well tied together
      # === @params: opts [Hash]
      #      * stub_responses: defaulted to false but it can be overriden with the desired responses for local testing
      #      * region: defaulted to use the `#region()` method
      #      * AWS::Credentials object, which will also scour the context and environment for your keys
      # === @returns: AWS::SNS client
      # === Sample Usage
      #     ```
      #       config = {
      #         stub_responses: {
      #           create_topic: {},
      #           delete_topic: {},
      #           list_topics: [],
      #           publish: {},
      #           subscribe: {}
      #         }
      #       }
      #
      #       sns(config) # sets and gets an Kinesis client
      #
      #       create_channel!('testBroadcast')
      #       # => true
      #     ```
      def sns(opts = {})
        config = {
          stub_responses: false,
          region: region,
          credentials: Auth.creds
        }
        config = config.merge(opts.select { |k| config.key?(k) })

        @sns ||= Aws::SNS::Client.new(config)
      end

      # Get or create an SQS client and cache that client so that a Context is more well tied together
      # === @params: opts [Hash]
      #      * stub_responses: defaulted to false but it can be overriden with the desired responses for local testing
      #      * region: defaulted to use the `#region()` method
      #      * AWS::Credentials object, which will also scour the context and environment for your keys
      # === @returns: AWS::SQS client
      # === Sample Usage
      #     ```
      #       config = stub_responses: {
      #         create_queue: {
      #           queue_url: "https://sqs.us-west-2.amazonaws.com/12345678/#{opts[:name] || 'testQueue'}"
      #         }
      #       }
      #
      #       sqs(config) # sets and gets an Kinesis client
      #
      #       create_queue('someQueue')
      #     ```
      def sqs(opts = {})
        config = {
          stub_responses: false,
          credentials: Auth.creds
        }
        config = config.merge(opts.select { |k| config.key?(k) })

        @sqs ||= Aws::SQS::Client.new(config)
      end
    end
  end
end
