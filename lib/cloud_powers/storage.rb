require 'pathname'
require_relative 'aws_resources'

module Smash
  module CloudPowers
    module Storage
      include Smash::CloudPowers::AwsResources

      def local_job_file_exists?(file)
        File.exists?(job_path(to_ruby_file_name(file)))
      end

      # Searches a local job storage location for the given +file+ name
      # if it exists - exit the method
      # if it does <i>not</i> exist - get the file from s3 and place it in
      # the directory that was just searched bucket using +#zfind()+
      #
      # Parameters
      # * file +String+ - the name of the file we're searching for
      #
      # Returns
      # nothing
      #
      # Example
      # * file tree
      #     project_root- |
      #                   |_sub_directory
      #                   |              |_current_file.rb
      #                   |_job_storage
      #                   |             |_demorific.rb
      #                   |             |_foobar.rb
      # * code:
      #     source_job('demorific')
      #     # file tree doesn't change because this file exists
      #     source_job('custom_greetings')
      #     # file tree now looks like this
      # * new file tree
      #     project_root- |
      #                   |_sub_directory
      #                   |              |_current_file.rb
      #                   |_job_storage
      #                   |             |_demorific.rb
      #                   |             |_foobar.rb
      #                   |             |_custom_greetings.js # could be an after effects JS script
      def source_job(file)
        # TODO: better path management
        bucket = zfind('job storage')
        if job_path(to_ruby_file_name(file)).nil?
          objects = s3.list_objects(bucket: bucket).contents.select do |f|
            /#{Regexp.escape file}/i =~ f.key
          end

          objects.each do |obj|
            s3.get_object(bucket: bucket, key: obj.key, response_target: job_path(file))
          end
        end
      end

      # Search through a bucket to find a file, based on a regex
      #
      # Parameters
      # * bucket +String+ - the bucket to search through in AWS
      # * pattern +Regexp+|+nil+ - the Regex pattern you want to use for the
      #   search.  nil doesn't cause an exception but probably returns <tt>[]</tt>
      #
      # Example
      #   matches = search('neuronJobs', /[Dd]emo\w*/)
      #   # => ['Aws::S3::Type::ListObjectOutPut','Aws::S3::Type::ListObjectOutPut',...] # anything that matched that regex
      #   matches.first.contents.size
      #   # => 238934 # integer representation of the file size
      def search(bucket, pattern)
        return [] if bucket.nil?

        begin
          pattern = /#{pattern}/ unless pattern.kind_of? Regexp
          s3.list_objects(bucket: bucket).contents.select do |o|
            o.key =~ pattern || /#{o.key}/ =~ pattern.to_s
          end
        rescue Aws::S3::Errors::NoSuchBucket => e
          logger.info format_error_message e
          return # log that the bucket doesn't exist but don't explode
        end
      end

      # Send the log files to the S3 log file bucket
      #
      # Returns
      # +Aws::S3::Type::PutObjectOutput+
      def send_logs_to_s3
        File.open(log_file) do |file|
          s3.put_object(
            bucket: log_bucket,
            key: instance_id,
            body: file
          )
        end
      end
    end
  end
end
