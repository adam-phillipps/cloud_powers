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
        zfind('Aws Region')
      end

      def ec2
        @ec2 ||= Aws::EC2::Client.new(
          region: region,
          credentials: Auth.creds
        )
      end

      def image(name)
        ec2.describe_images(
          filters: [{ name: 'tag:aminame', values: [name.to_s] }]
        ).images.first
      end

      def kinesis
        @kinesis ||= Aws::Kinesis::Client.new(
          region: region,
          credentials: Auth.creds,
        )
      end

      def s3
        @s3 ||= Aws::S3::Client.new(
          region: region,
          credentials: Auth.creds
        )
      end
    end
  end
end
