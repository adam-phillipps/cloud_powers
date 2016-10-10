require 'aws-sdk'
Aws.use_bundled_cert!
require_relative 'zenv'

module Smash
  module CloudPowers
    module Auth
      extend Smash::CloudPowers::Zenv

      # This method is able to be called before an object is instantiated in order
      # to provide a region in AWS-land.
      # === @returns: The region set in configuration or a 'us-west-2' default String
      def self.region
        zfind(:aws_region) || 'us-west-2'
      end

      # This method is able to be called before an object is instantiated in order
      # to provide an Aws::Credentials object that will allow access to all the
      # resources in the account that zfind searches for, using the "ACCOUNT_NUMBER"
      # key.
      def self.creds
        @creds ||= Aws::Credentials.new(
          zfind(:aws_access_key_id),
          zfind(:aws_secret_access_key)
        )
      end
    end
  end
end
