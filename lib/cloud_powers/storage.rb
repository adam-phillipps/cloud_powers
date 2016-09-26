require 'pathname'
require_relative 'aws_resources'

module Smash
  module CloudPowers
    module Storage
      include Smash::CloudPowers::AwsResources

      def source_task(file)
        # TODO: better path management
        bucket = zfind('task storage')
        unless task_path(file).exist?
          objects = s3.list_objects(bucket: bucket).contents.select do |f|
            /#{Regexp.escape file}/i =~ f.key
          end
          objects.each do |obj|
            s3.get_object(bucket: bucket, key: obj.key, response_target: task_path(file))
          end
        end
      end

      def search(bucket, pattern)
        s3.list_objects(bucket: bucket).contents.select do |o|
          o.key =~ pattern
        end
      end

      def send_logs_to_s3
        File.open(log_file) do |file|
          s3.put_object(
            bucket: log_bucket,
            key: @instance_id,
            body: file
          )
        end
      end
    end
  end
end
