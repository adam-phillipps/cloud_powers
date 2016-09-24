require 'aws-sdk'
Aws.use_bundled_cert!
require 'httparty'
require_relative 'aws_resources'
require_relative 'helper'
require_relative './synapse/synapse'

module Smash
  module CloudPowers
    module SelfAwareness
      extend Smash::CloudPowers::Helper
      extend Smash::CloudPowers::Synapse::Pipe
      extend Smash::CloudPowers::Synapse::Queue
      include Smash::CloudPowers::AwsResources

      # gets the instance time or the time it was called and as seconds from
      # epoch
      # TODO: use time codes
      def boot_time
        begin
          @boot_time ||=
            ec2.describe_instances(dry_run: env('testing'), instance_ids:[@instance_id]).
              reservations[0].instances[0].launch_time.to_i
        rescue Aws::EC2::Errors::DryRunOperation => e
          logger.info "dry run for testing: #{e}"
          @boot_time ||= Time.now.to_i # comment the code below for development mode
        end
      end

      # Send a status message on the status Pipe then terminates the instance.
      def die!
        Thread.kill(@status_thread) unless @status_thread.nil?
        # blame = errors.sort_by(&:reverse).last.first
        logger.info("The cause for the shutdown is TODO: fix SmashErrors")

        pipe_to(:status_stream) do
          {
            instanceID: @instance_id,
            type: 'status-update',
            content: 'dying'
            # extraInfo: blame
          }
        end

        [:count, :wip].each do |queue|
          delete_queue_message(queue, max_number_of_messages: 1)
        end
        send_logs_to_s3
        begin
          ec2.terminate_instances(dry_run: env('testing'), ids: [@instance_id])
        rescue Aws::EC2::Error::DryRunOperation => e
          logger.info "dry run testing in die! #{format_error_message(e)}"
          @instance_id
        end
      end

      # Get resource metadata, public host, boot time and task name
      # and set them as instance variables
      def get_awareness!
        keys = metadata_request
        attr_map!(keys) { |key| metadata_request(key) }
        boot_time # gets and sets @boot_time
        task_name # gets and sets @task_name
        instance_url # gets and sets @instance_url
      end

      # Check self-tags for 'task' and act as an attr_accessor.
      # A different node's tag's can be checked for a task by passing
      # the id param
      # see also: SelfAwareness#task_names
      def task_name(id = @instance_id)
        # get @task_name
        return @task_name unless @task_name.nil?
        # set @task_name
        resp = ec2.describe_instances(instance_ids: [id].flatten)
        @task_name = resp.reservations[0].instances[0].tags.select do |t|
          t.value if t.key == 'taskType'
        end.first
      end

      # Gets and sets the public hostname of the instance
      def instance_url
        @instance_url ||= if env('TESTING')
          'https://test-url.com'
        else
          hostname_uri = 'http://169.254.169.254/latest/meta-data/public-hostname'
          HTTParty.get(hostname_uri).parsed_response
        end
      end

      # Makes the http request to self/meta-data to get all the metadata keys or,
      # if a key is given, the method makes the http request to get that
      # particular key from the metadata
      # @param: [key <String>]
      def metadata_request(key = '')
        unless env('TESTING')
          metadata_uri = "http://169.254.169.254/latest/meta-data/#{key}"
          HTTParty.get(metadata_uri).parsed_response.split("\n")
        else
          @z ||= ['i-9254d106', 'ami-id', 'ami-launch-index', 'ami-manifest-path', 'network/thing']
          if key == ''
            @boogs = ['instance-id', 'ami-id', 'ami-launch-index', 'ami-manifest-path', 'network/interfaces/macs/mac/device-number']
          else
            @z.shift
          end
        end
      end

      def run_time
        # TODO: refactor to use valid time stamps for better tracking.
        # reason -> separate regions or OSs etc.
        Time.now.to_i - boot_time
      end

      def send_frequent_status_updates(opts = {})
        sleep_time = opts.delete(:interval) || 10
        stream = opts.delete(:stream_name)
        while true
          message = lambda { |o| update_message_body(o.merge(content: status)) }
          logger.info "Send update to status board #{message.call(opts)}"
          pipe_to(stream || :status_stream) { message.call(opts) }
          sleep sleep_time
        end
      end

      def status(id = @instance_id)
        begin
          ec2.describe_instances(dry_run: env('testing'), instance_ids: [id]).
            reservations[0].instances[0].state.name
        rescue Aws::EC2::Errors::DryRunOperation => e
          logger.info "Dry run flag set for testing: #{format_error_message(e)}"
          'testing'
        end
      end

      def time_is_up?
        # returns true when the hour mark approaches
        an_hours_time = 60 * 60
        five_minutes_time = 60 * 5

        return false if run_time < five_minutes_time
        run_time % an_hours_time < five_minutes_time
      end
    end
  end
end
