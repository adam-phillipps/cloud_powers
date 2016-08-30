require_relative 'auth'

module Smash
  module CloudPowers
    extend CloudPowers::Auth
    module AwsResources

      def region
        env('AWS_REGION')
      end

      def ec2
        @ec2 ||= Aws::EC2::Client.new(
          region: region,
          credentials: Auth.creds
        )
      end
    end
  end
end
