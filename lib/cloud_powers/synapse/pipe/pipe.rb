module Smash
  module CloudPowers
    module Synapse
      module Pipe
        include Smash::CloudPowers::AwsResources
        include Smash::CloudPowers::Helpers
        include Smash::CloudPowers::Zenv

        def create_resource(name:, **opts)

        # Create a Kinesis stream or wait until the stream with the given name is
        # through being created.
        #
        # Parameters
        # * name +String+
        #
        # Returns Boolean or nil
        # * returns true or false if the request was successful or not
        # * returns true if the stream has already been created
        # * returns false if the stream was not created
        def create_stream(name)
          begin
            config = stream_config(stream_name: name)
            resp = kinesis.create_stream(config)
            kinesis.wait_until(:stream_exists, stream_name: config[:stream_name])
            resp.successful? # (http request successful && stream created)?
          rescue Exception => e
            if e.kind_of? Aws::Kinesis::Errors::ResourceInUseException
              logger.info "#{name} already created"
              return if stream_status(name) == 'ACTIVE'
              logger.info "Not ready for traffic.  Wait for 30 seconds..."
              sleep 1
              true # acts like it would if it had to create the stream
            else
              error_message = format_error_message(e)
              logger.error error_message
              false # the request was not successful
            end
          end
        end

        # Use the KCL and LangDaemon to read from a stream
        #
        # Parameters stream String
        #
        # Notes
        # * This method is not implemented yet (V 0.2.7)
        def flow_from_pipe(stream)
          throw NotImplementedError
        end

        # Sends data through a Pipe.  This method is used for lower throughput
        # applications, e.g. logging, status updates
        #
        # Parameters
        # * stream +String+
        #
        # Returns
        # @last_sequence_number +String+
        #
        # Notes
        # * This method is not implemented yet (V 0.2.7)
        def flow_to_pipe(stream)
          throw NotImplementedError
          create_stream(stream) unless stream_exists? stream
          records = yield if block_given?
          body = message_body_collection(records)
          puts body
          # TODO: this isn't working yet.  figure out retry logic
          # resp = kinesis.put_records(body)
          # retry(lambda { stream_exists? stream }) flow_to(stream)
          @last_sequence_number = resp.records.map(&:sequence_number).sort.last
          # TODO: what to return? true?
        end

        # Read messages from the Pipe without using the KCL
        #
        # Parameters stream String
        #
        # Notes
        # * This method is not implemented yet (V 0.2.7)
        def from_pipe(stream)
          # implement get_records and/or other consuming app stuff
          throw NotImplementedError
        end

        # This message will prepare a set of collections to be sent through the Pipe
        #
        # Parameters
        # * records
        #
        # Notes
        # * This method is not implemented yet (V 0.2.7)
        def message_body_collection(records)
          throw NotImplementedError
        end

        # Default message package.  This method yields the basic configuration
        # and message body for a stream and all options can be changed.
        #
        # Parameters opts Hash (optional)
        # * stream_name:    String name of the stream to pipe to
        # * data:           String message to send
        # * partition_key:  String defaults to  @instance_id
        #
        # Returns
        # +Hash+
        #
        # Notes
        # * See +#zfind()+
        # * See +#instance_id()+
        # * See +#update_message_body()+
        def pipe_message_body(opts = {})
          {
            stream_name:      zfind(opts[:stream_name]) || zfind('status_stream'),
            data:             opts[:data] || update_message_body(opts),
            partition_key:    opts[:partition_key] || @instance_id || 'unk'
          }
        end

        # Use Kinesis streams to send a message.  The message is given to the method
        # through a block that gets passed to the method.
        #
        # Parameters
        # * stream +String+
        # * block - a block that generates a string that will be used in the message body
        #
        # Returns
        # the sequence_number from the sent message.
        #
        # Example
        #   pipe_to(:status_stream) do
        #     # the return from the inner method is what is sent
        #     do_some_stuff_to_generate_a_message()
        #   end
        def pipe_to(stream)
          message = ''
          create_stream() unless stream_exists?(zfind(stream) || stream)
          message = yield if block_given?
          body = update_message_body(message)
          resp = kinesis.put_record pipe_message_body(stream_name: stream, data: body.to_json)
          # TODO: implement retry logic for failed request
          @last_sequence_number = resp.sequence_number
        end

        # New stream config with sensible defaults
        #
        # Parameters
        # * opts +Hash+ (optional)
        # * * stream_name - the name to give the stream
        # * * shard_count - the number of shards to create
        def stream_config(opts = {})
          {
            stream_name: opts[:stream_name] || zfind(:status_stream),
            shard_count: opts[:shard_count] || 1
          }
        end

        # Find out if the stream already exists.
        #
        # Parameters
        # * name +String+
        #
        # Returns
        # +Boolean+
        def stream_exists?(name)
          begin
            kinesis.describe_stream(stream_name: name)
            true
          rescue Aws::Kinesis::Errors::ResourceNotFoundException
            false
          end
        end

        # Get the status name for this stream
        #
        # Parameters
        # *name +String+
        #
        # Returns
        # +String+ - stream status, one of: CREATING, DELETING, ACTIVE or UPDATING
        def stream_status(name)
          kinesis.describe_stream(stream_name: name).stream_description.stream_status
        end
      end
    end
  end
end
