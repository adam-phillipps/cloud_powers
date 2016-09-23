module Smash
  module CloudPowers
    module Synapse
      include Smash::CloudPowers::Helper

      module Pipe
        def create_stream(name)
          begin
            config = stream_config(stream_name: env(name))
            resp = kinesis.create_stream(config)
            kinesis.wait_until(:stream_exists, stream_name: config[:stream_name])
            resp.successful? # (http request successful && stream created)?
          rescue Exception => e
            if e.kind_of? Aws::Kinesis::Errors::ResourceInUseException
              logger.info "#{name} already created"
              stream_status = kinesis.describe_stream(name).stream_description.stream_status
              return if stream_status == 'ACTIVE'
              logger.info "Not ready for traffic.  Wait for 30 seconds..."
              sleep 30
              nil # no request -> no response
            else
              # TODO: make the errors thing work
              error_message = format_error_message(e)
              logger.error error_message
              false # the request was not successful
            end
          end
        end

        def flow_from_pipe(stream)
          throw NotImplementedError
        end

        def flow_to_pipe(stream)
          create_stream(stream) unless stream_exists? stream
          records = yield if block_given?
          body = message_body_collection(records)
          # TODO: this isn't working yet.  figure out retry logic
          # resp = kinesis.put_records(body)
          # retry(lambda { stream_exists? stream }) flow_to(stream)
          @last_sequence_number = resp.records.map(&:sequence_number).sort.last
          # TODO: what to return? true?
        end

        def from_pipe(stream)
          # implemented get_records and/or other consuming app stuff
          throw NotImplementedError
        end

        def message_body_collection(records)
          throw NotImplementedError
        end

        def pipe_message_body(opts = {})
          {
            stream_name:      env(opts[:stream_name]) || env('status_stream'),
            data:             opts[:data] || update_message_body(opts),
            partition_key:    opts[:partition_key] || @instance_id
          }
        end

        def pipe_to(stream)
          create_stream(stream) unless stream_exists? stream
          message = yield if block_given?
          body = update_message_body(message)
          resp = kinesis.put_record pipe_message_body(stream_name: stream, data: body.to_json)
          # TODO: implement retry logic for failed request
          @last_sequence_number = resp.sequence_number
        end

        def stream_config(opts = {})
          config = {
            stream_name: opts[:stream_name] || env('status_stream'),
            shard_count: opts[:shard_count] || 1
          }
        end

        def stream_exists?(name)
          begin
            kinesis.describe_stream(stream_name: env(name))
          rescue Aws::Kinesis::Errors::ResourceNotFoundException => e
            false
          end
        end
      end
    end
  end
end
