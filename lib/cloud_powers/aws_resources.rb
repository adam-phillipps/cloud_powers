require_relative 'auth'
require_relative 'helper'
require_relative 'zenv'

module Smash
  module CloudPowers
    module AwsResources
      include Smash::CloudPowers::Auth
      include Smash::CloudPowers::Helper
      include Smash::CloudPowers::Zenv

      def region
        zfind(:aws_region) || 'us-west-2'
      end

      def ec2(opts = {})
        config = {
          stub_responses: false,
          region: region,
          credentials: Auth.creds
        }
        config = config.merge(opts.select { |k| config.key?(k) })

        @ec2 ||= Aws::EC2::Client.new(config)
      end

      def image(name, opts = {})
        config = {
          filters: [{ name: 'tag:aminame', values: [name.to_s] }]
        }
        config = config.merge(opts.select { |k| config.key?(k) })

        ec2(opts).describe_images(config).images.first
      end

      def kinesis(opts = {})
        config = {
          stub_responses: false,
          region: region,
          credentials: Auth.creds
        }
        config = config.merge(opts.select { |k| config.key?(k) })

        @kinesis ||= Aws::Kinesis::Client.new(config)
      end

      def s3(opts = {})
        config = {
          stub_responses: false,
          region: region,
          credentials: Auth.creds
        }
        config = config.merge(opts.select { |k| config.key?(k) })

        @s3 ||= Aws::S3::Client.new(config)
      end

      def sns(opts = {})
        config = {
          stub_responses: false,
          region: region,
          credentials: Auth.creds
        }
        config = config.merge(opts.select { |k| config.key?(k) })

        @sns ||= Aws::SNS::Client.new(config)
      end

      def sqs(opts = {})
        @sqs ||= Aws::SQS::Client.new({
            credentials: Auth.creds
          }.merge(opts)
        )
      end
    end
  end
end
