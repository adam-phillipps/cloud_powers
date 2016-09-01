require 'aws-sdk'
Aws.use_bundled_cert!

module Smash
  module CloudPowers
    module Auth
<<<<<<< HEAD
=======

>>>>>>> 7e4749ab855d2300f6e8e48095519e33c17e4fc3
      def self.creds
        @creds ||= Aws::Credentials.new(
          ENV['AWS_ACCESS_KEY_ID'],
          ENV['AWS_SECRET_ACCESS_KEY']
        )
      end
    end
  end
end
