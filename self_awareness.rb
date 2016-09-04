require 'aws-sdk'
Aws.use_bundled_cert!
# require 'syslog/logger'
# require 'logger'
require 'httparty'
# require_relative 'auth'
# require_relative 'aws_resources'
require_relative 'helper'
require_relative './synapse/synapse'

module Smash
  module CloudPowers
    # extend Auth
    # extend Helper
    extend Smash::CloudPowers::Synapse::Pipe
    extend Smash::CloudPowers::Synapse::Queue
    # extend AwsResources

    module SelfAwareness
      # extend Auth
      extend Smash::CloudPowers::Helper
      extend Smash::CloudPowers::Synapse::Pipe
      extend Smash::CloudPowers::Synapse::Queue
      # extend AwsResources

      def die!
        Thread.kill(@status_thread) unless @status_thread.nil?
        blame = errors.sort_by(&:reverse).last.first
        logger.info("The cause for the shutdown is #{blame}")

        pipe_to(:status_stream) do
          {
            instanceID: @instance_id,
            type: 'status_update',
            content: 'dying',
            extraInfo: blame
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
        end
      end

      def get_awareness!
        keys = metadata_request
        attr_map!(keys) { |key| metadata_request(key) }
        boot_time # sets @boot_time
      end

      def get_an_identity!(task_identity)
        @identity ||= task_identity
      end

      def metadata_request(key = '')
        # metadata_uri = "http://169.254.169.254/latest/meta-data/#{key}"
        # HTTParty.get(metadata_uri).parsed_response.split("\n")
        @respssss ||= ['i-9254d106', 'ami-id', 'ami-launch-index', 'ami-manifest-path', 'network/thing']
        if key == ''
          @boogs = ['instance-id', 'ami-id', 'ami-launch-index', 'ami-manifest-path', 'network/interfaces/macs/mac/device-number']
        else
          @respssss.shift
        end
      end

      def rubyize(var_name)
        "@#{var_name.gsub(/\W/, '_').downcase}"
      end

      def run_time
        Time.now.to_i - boot_time
      end

      def send_frequent_status_updates(opts = {})
        # TODO: this method can't be right.  opts or config? use one
        sleep_time = opts.delete(:interval) || 10
        config = pipe_message_body(opts)
        stream = config[:stream_name]
        while true
          logger.info "Send update to status board #{update_message_body}"

          pipe_to(opts[:stream_name] || :status_stream) do
            edit = opts.merge({ content: status })
            update_message_body(edit)
          end

          sleep sleep_time
        end
      end

      def boot_time
        # testing
        # begin
          # @boot_time ||=
            # ec2.describe_instances(dry_run: env('testing'), instance_ids:[@instance_id]).
              # reservations[0].instances[0].launch_time.to_i
        # rescue Aws::EC2::Errors::DryRunOperation => e
          # logger.info "dry run for testing: #{format_error_message(e)}"
          @boot_time ||= Time.now.to_i # comment the code below for development mode
        # end
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
        (run_time % 60) < 5
      end
    end
  end
end
