require 'aws-sdk'
Aws.use_bundled_cert!
require_relative 'zenv'

module Smash
  module CloudPowers
    # Provides authentication to cloud resources, e.g. AWS
    module Auth
      extend Smash::CloudPowers::Zenv

      # This method is usable before an object is instantiated in order
      # to provide an <tt>Aws::Credentials</tt> object that will allow access to all the
      # resources in the account that zfind searches for, using the <tt>ACCOUNT_NUMBER</tt>
      # key.
      #
      # Returns
      # <tt>Aws::Credentials</tt>
      #
      # Example
      #   Auth.creds
      #   => Aws::Credentials # can be used to authenticate to AWS
      #
      # Notes
      # * This method relies on +#zfind()+ to locate the key/secret strings
      # * See +Smash::CloudPowers::Zenv#zfind()+
      def self.creds
        @creds ||= Aws::Credentials.new(
          zfind(:aws_access_key_id),
          zfind(:aws_secret_access_key)
        )
      end

      # This method is able to be called before an object is instantiated in order
      # to provide a region in AWS-landia.
      #
      # Returns
      # The region set in configuration or a <tt>'us-west-2'</tt> default <tt>String</tt>
      #
      # Example
      #   Auth.region
      #   => 'us-east-1'
      def self.region
        zfind(:aws_region) || 'us-west-2'
      end
    end
  end
end
