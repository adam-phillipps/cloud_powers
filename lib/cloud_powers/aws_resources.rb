require_relative 'auth'

module Smash
  module CloudPowers
    module AwsResources
      extend Smash::CloudPowers::Auth

      def region
        env('Aws Region')
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
    end
  end
end
