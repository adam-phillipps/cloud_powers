require 'aws-sdk'
Aws.use_bundled_cert!

module Smash
  module CloudPowers
    module Synapse
      module Pipe
        def create_stream(name)
          begin
            config = stream_config(stream_name: env(name))
            resp = kinesis.create_stream(config)
            kinesis.wait_until(:stream_exists, stream_name: config[:stream_name])
            resp.successful? # (http request successful && stream created)?
          rescue Exception => e
            if e.kind_of? Aws::Kinesis::Errors::ResourceInUseException
              logger.info "Stream already created"
              # let the stream get ready for traffic because it was probably
              # just created by another process or neuron
              # TODO: find out how to only sleep when the status isn't active
              sleep 30
              nil # no request -> no response
            else
              error_message = format_error_message(e)
              logger.error error_message
              errors.push_error!(:ruby, error_message) # throws: :die, :failed_job
              errors[:ruby] << error_message
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

        def kinesis
          @kinesis ||= Aws::Kinesis::Client.new(
            region: region,
            credentials: Auth.creds,
          )
        end

        def message_body_collection(records)
          throw NotImplementedError
        end

        def pipe_message_body(opts = {})
          {
            stream_name:      opts[:stream_name] || env('status_stream'),
            data:             opts[:data] || update_message_body(opts),
            partition_key:    opts[:partition_key] || @instance_id
          }
        end

        def pipe_to(stream)
          create_stream(stream) unless stream_exists? stream
          message = yield if block_given?
          body = update_message_body(content: message)
          resp = kinesis.put_record pipe_message_body(data: body)
          # TODO: implement retry logic for failed request
          @last_sequence_number = resp.sequence_number
          # TODO: return message id or something
        end

        def stream_config(opts = {})
          config = {
            stream_name: opts[:stream_name] || env('status_stream'),
            shard_count: opts[:shard_count] || 1
          }
        end

        def stream_exists?(name)
          begin
            kinesis.describe_stream(stream_name: name)
          rescue Aws::Kinesis::Errors::ResourceNotFoundException => e
            false
          end
        end
      end
    end
  end
end
