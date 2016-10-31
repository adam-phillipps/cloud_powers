require_relative 'auth'
require_relative 'zenv'

module Smash
  module CloudPowers
    module AwsResources
      include Smash::CloudPowers::Auth
      include Smash::Helpers
      include Smash::CloudPowers::Zenv

      # Get the region from the environment/context or use a default region for AWS API calls.
      #
      # Returns
      # +String+
      def region
        zfind(:aws_region) || 'us-west-2'
      end

      # Get or create an EC2 client and cache that client so that a Context is more well tied together
      #
      # Parameters
      # * opts +Hash+ (optional)
      # * * stub_responses - defaulted to +false+ but it can be overriden with the desired responses for local testing
      # * * region - defaulted to use the <tt>#region()</tt> method
      # * * AWS::Credentials object, which will also scour the context and environment for your keys
      #
      # Returns
      # +AWS::EC2::Client+
      #
      # Example
      #   images = ec2.describe_images
      #   images.first[:image_id]
      #   # => 'asdf'
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
      #
      # Parameters
      # * opts [Hash]
      # * * stub_responses: defaulted to false but it can be overriden with the desired responses for local testing
      # * * region: defaulted to use the `#region()` method
      # * * AWS::Credentials object, which will also scour the context and environment for your keys
      #
      # Returns
      # Aws::EC2::Image
      def image(name, opts = {})
        config = {
          filters: [{ name: 'tag:aminame', values: [name.to_s] }]
        }
        config = config.merge(opts.select { |k| config.key?(k) })

        ec2(opts).describe_images(config).images.first
      end

      # Get or create an Kinesis client and cache that client so that a Context is more well tied together
      #
      # Parameters
      # * opts <tt>Hash</tt>
      # * * stub_responses: defaulted to false but it can be overriden with the desired responses for local testing
      # * * region: defaulted to use the `#region()` method
      # * * AWS::Credentials object, which will also scour the context and environment for your keys
      #
      # Returns
      # +AWS::Kinesis client+
      #
      # Example
      #   pipe_to('somePipe') { update_body(status: 'waHoo') } # uses Aws::Kinesis::Client.put_recor()
      #   # => sequence_number: '1676151970'
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
      #
      # Parameters
      # * opts <tt>Hash</tt>
      # * * stub_responses: defaulted to false but it can be overriden with the desired responses for local testing
      # * * region: defaulted to use the `#region()` method
      # * * AWS::Credentials object, which will also scour the context and environment for your keys
      #
      # Returns
      # +AWS::S3 client+
      #
      # Example
      #   expect(s3.head_bucket('exampleBucket')).to be_empty
      #   # passing test
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
      # Parameters
      # * opts +Hash+
      # * * stub_responses: defaulted to false but it can be overriden with the desired responses for local testing
      # * * region: defaulted to use the `#region()` method
      # * * AWS::Credentials object, which will also scour the context and environment for your keys
      #
      # Returns
      # +AWS::SNS client+
      #
      # Example
      #   create_channel!('testBroadcast') # uses Aws::SNS::Client
      #   # => true
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
      #
      # Parameters
      # * opts <tt>Hash</tt>
      # * * stub_responses: defaulted to false but it can be overriden with the desired responses for local testing
      # * * region: defaulted to use the `#region()` method
      # * * AWS::Credentials object, which will also scour the context and environment for your keys
      #
      # Returns
      # +AWS::SQS client+
      #
      # Example
      #   create_queue('someQueue') # Uses Aws::SQS::Client
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
