require 'aws-sdk'
Aws.use_bundled_cert!
require 'httparty'
require 'stubs/aws_stubs'
require_relative 'aws_resources'
require_relative 'helper'
require_relative './synapse/synapse'
require_relative 'zenv'

module Smash
  module CloudPowers
    module SelfAwareness
      extend Smash::CloudPowers::Helper
      extend Smash::CloudPowers::Synapse::Pipe
      extend Smash::CloudPowers::Synapse::Queue
      extend Smash::CloudPowers::Zenv
      include Smash::CloudPowers::AwsResources

      # Gets the instance time or the time it was called and as seconds from
      # epoch
      #
      # Returns Integer
      #
      # Notes
      # * TODO: use time codes
      def boot_time
        begin
          @boot_time ||=
            ec2.describe_instances(dry_run: zfind(:testing), instance_ids:[instance_id]).
              reservations[0].instances[0].launch_time.to_i
        rescue Aws::EC2::Errors::DryRunOperation
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
          ec2.terminate_instances(dry_run: zfind('testing'), ids: [@instance_id])
        rescue Aws::EC2::Error::DryRunOperation
          logger.info "dry run testing in die! #{format_error_message(e)}"
          @instance_id
        end
      end

      # Get resource metadata, public host, boot time and task name
      # and set them as instance variables
      #
      # Returns
      # +Array+ of values, each from a separate key, set in the order
      # in the Array
      #
      # Notes
      # * See +#metadata_request()+
      # * See +#attr_map!()+
      def get_awareness!
        keys = metadata_request
        attr_map!(keys) { |key| metadata_request(key) }
        boot_time # gets and sets @boot_time
        task_name # gets and sets @task_name
        instance_url # gets and sets @instance_url
      end

      # Assures there is always a valid instance id because many other Aws calls require it
      #
      # Returns
      # +String+
      def instance_id
        @instance_id ||= metadata_request('instance_id')
      end

      # Gets and sets the public hostname of the instance
      #
      # Returns
      # +String+ - the Public Hostname for this instance
      #
      # Notes
      # * When this is being called from somewhere other than an Aws instance,
      #   a hardcoded example URL is returned because of the way instance metadata is retrieved
      def instance_url
        @instance_url ||= unless zfind('TESTING')
          hostname_uri = 'http://169.254.169.254/latest/meta-data/public-hostname'
          HTTParty.get(hostname_uri).parsed_response
        else
          'http://ec2-000-0-000-00.compute-0.amazonaws.com'
        end
      end

      # Makes the http request to self/meta-data to get all the metadata keys or,
      # if a key is given, the method makes the http request to get that
      # particular key from the metadata
      #
      # Parameters
      # * key +String+ (optional) (default is '') - the key for the metadata information
      #   you want from this instance.
      #
      # Returns
      # * +Array+ if key is blank
      # * +String+ if key is given
      #
      # Example
      #   metadata_request
      #   # => a +Hash+ containing every key => value pair AWS provides
      #   metadata_request('instance-id')
      #   # => 'abc-1234'
      def metadata_request(key = '')
        key = to_hyph(key)
        begin
          unless zfind('TESTING')
            metadata_uri = "http://169.254.169.254/latest/meta-data/#{key}"
            HTTParty.get(metadata_uri).parsed_response.split("\n")
          else
            stubbed_metadata = Smash::CloudPowers::AwsStubs.instance_metadata_stub

            key.empty? ? stubbed_metadata.keys : stubbed_metadata[to_hyph(key)]
          end
        rescue Exception => e
          logger.fatal format_error_message e
        end
      end

      # Return the time since boot_time
      #
      # Returns
      # +Integer+
      #
      # Notes
      # * TODO: refactor to use valid time stamps for better tracking.
      # * reason -> separate regions or OSs etc.
      def run_time
        Time.now.to_i - boot_time
      end

      # Send a message on a Pipe at an interval
      #
      # Parameters
      # * opts +Hash+ (optional)
      # * * +:interval+ - how long to wait between sending updates
      # * * +:stream_name+ - name of stream you want to use
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

      # Get the instance status.
      #
      # Parameters
      # * id +String+ (optional) (default is @instance_id)
      #
      # Returns String
      def status(id = @instance_id)
        begin
          ec2.describe_instances(dry_run: zfind('TESTING'), instance_ids: [id]).
            reservations[0].instances[0].state.name
        rescue Aws::EC2::Errors::DryRunOperation
          logger.info "Dry run flag set for testing: #{e}"
          'testing'
        end
      end


      # Search through tags on an instances using a regex pattern for your tag's
      # key/name.  This method returns only 1 valid result or nil.
      #
      # Parameters
      # * pattern +String+|+Regex+
      #
      # Returns
      # * +String+ - if a tag is found
      # * +nil+ - if a tag is not found
      #
      # Notes
      # * This method returns only the first valid result or nil
      def tag_search(pattern, id = @instance_id)
        resp = ec2.describe_instances(instance_ids: [id].flatten).reservations.first
        return nil if resp.nil?
        resp.instances[0].tags.select do |tag|
          tag.value if (tag.key =~ %r[#{pattern}])
        end.collect.map(&:value).first
      end

      # Check self-tags for 'task' and act as an attr_accessor.
      # A different node's tag's can be checked for a task by passing
      # that instance's id as a parameter
      #
      # Parameters
      # * id +String+ (optional) (default is @instance_id) - instance you want a tag from
      #
      # Returns
      # +String+
      #
      # Notes
      # * See <tt>tag_search()</tt>
      def task_name(id = @instance_id)
        # get @task_name
        return @task_name unless @task_name.nil?
        # set @task_name
        # TODO: get all tasks instead of just the first
        @task_name = tag_search('task', id)
      end

      # This method will return true if:
      # * The run time is more than 5 minutes
      # and
      # * The run time is 5 minutes from the hour mark from when the instance started
      # and will return false otherwise
      #
      # Returns
      # +Boolean+
      def time_is_up?
        an_hours_time = 60 * 60
        five_minutes_time = 60 * 5

        return false if run_time < five_minutes_time
        run_time % an_hours_time < five_minutes_time
      end
    end
  end
end
