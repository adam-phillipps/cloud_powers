module Smash
  module CloudPowers
    module Storage
      def s3
        @s3 ||= Aws::S3::Client.new(
          region: region,
          credentials: creds
        )
      end

      def send_logs_to_s3
        File.open(log_file) do |file|
          s3.put_object(
            bucket: log_bucket,
            key: self_id,
            body: file
          )
        end
      end
    end
  end
end
