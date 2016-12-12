module Smash
  module CloudPowers
    module Synapse
      module Pipe
        class Stream < Smash::CloudPowers::Resource

          attr_accessor :kinesis, :shard_count

          def initialize(name:, client: kinesis, **config)
            super
            @kinesis = client
            @shard_count = config[:shard_count] || 1
          end

          def create_resource
            begin
              @response = kinesis.create_stream(config)
              kinesis.wait_until(:stream_exists, stream_name: config[:stream_name])
              @response.successful? # (http request successful && stream created)?
            rescue Exception => e
              if e.kind_of? Aws::Kinesis::Errors::ResourceInUseException
                logger.info "#{name} already created"
                return if stream_status == 'ACTIVE'
                logger.info "Not ready for traffic.  Wait for 30 seconds..."
                sleep 1
                @saved = true # acts like it would if it had to create the stream
                @linked = true
              else
                raise
              end
            end
          end

          def config
            { stream_name: @name, shard_count: @shard_count }
          end
        end
      end
    end
  end
end
