require 'aws-sdk'
Aws.use_bundled_cert!

module Smash
  module CloudPowers
    module Auth
      def self.creds
        @creds ||= Aws::Credentials.new(
          ENV['AWS_ACCESS_KEY_ID'],
          ENV['AWS_SECRET_ACCESS_KEY']
        )
      end
    end
  end
end
