require 'aws-sdk'
Aws.use_bundled_cert!
require_relative 'zenv'

module Smash
  module CloudPowers
    module Auth
      extend Smash::CloudPowers::Zenv

      def self.creds
        @creds ||= Aws::Credentials.new(
          zfind('AWS_ACCESS_KEY_ID'),
          zfind('AWS_SECRET_ACCESS_KEY')
        )
      end
    end
  end
end
