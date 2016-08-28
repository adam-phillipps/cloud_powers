require 'aws-sdk'
Aws.use_bundled_cert!

module Smash
  module CloudPowers
    module Pipe
      def stream_config(opts = {})
        config = {
          stream_name: status_stream_name,
          shard_count: 1
        }.merge(opts)
      end

      def create_stream(name)
        begin
          config = stream_config(stream_name: name)
          resp = kinesis.create_stream(config)
          kinesis.wait_until(:stream_exists, stream_name: config[:stream_name])
          resp.successful? # (http request successful && stream created)?
        rescue Exception => e
          if e.kind_of? Aws::Kinesis::Errors::ResourceInUseException
            logger.info "Stream already created"
            # let the stream get ready for traffic because it was probably
            # just created by another process or neuron
            sleep 30
            nil # no request -> no response
          else
            error_message = format_error_message(e)
            logger.error error_message
            # TODO:
            # create error struct and add a #push(type: source, error: error_message)
            # errors.push!(type: :ruby, error: error_message) # throws: :die, :failed_job
            errors[:ruby] << error_message
            false # "request" was not successful
          end
        end
      end

      def from(stream)
        # implemented get_records and/or other consuming app stuff
        throw NotImplementedError
      end

      def flow_to(stream)
        create_stream(stream) unless stream_exists? stream
        records = yield if block_given?
        body = message_body_collection(records)
        # TODO: this isn't working yet.  figure out retry logic
        # resp = kinesis.put_records(body)
        # retry(lambda { stream_exists? stream }) flow_to(stream)
        @last_sequence_number = resp.records.map(&:sequence_number).sort.last
        # TODO: what to return? true?
      end

      def kinesis
        @kinesis ||= Aws::Kinesis::Client.new(
          region: region,
          credentials: creds,
        )
      end

      def pipe_message_body(opts = {})
        {
          stream_name:      opts[:stream_name] || env('status_stream_name'),
          data:             opts[:data] || update_message_body(opts),
          partition_key:    opts[:partition_key] || @instance_id
        }
      end

      def message_body_collection(records)
        throw NotImplementedError
      end

      def stream_exists?(name)
        begin
          kinesis.describe_stream(stream_name: name)
        rescue Exception => e
          byebug
        end
      end

      def to(stream)
        message = yield if block_given?
        body = pipe_message_body(message)
        kinesis.put_record pipe_message_body(body)
        # TODO: implement retry logic for failed request
        @last_sequence_number = resp.records.map(&:sequence_number).sort.last
        # TODO: what to return? true?
      end
    end
  end
end
