require_relative 'helper'

module Smash
  module CloudPowers
    module Auth
      include Smash::CloudPowers::Helper

      def creds
        @creds ||= Aws::Credentials.new(
          env('AWS_ACCESS_KEY_ID'),
          env('AWS_SECRET_ACCESS_KEY')
        )
      end
    end
  end
end
