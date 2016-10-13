module Smash
  module CloudPowers
    # Provides stubbing for development work in CloudPowers or in a project that uses is
    module AwsStubs

      # Stub metadata for EC2 instance
      def instance_metadata_stub(opts = {})
        {
          'ami-id' => 'ami-1234',
          'ami-launch-index' => '1',
          'ami-manifest-path' => '',
          'block-device-mapping/' => '',
          'hostname' => '',
          'instance-action' => '',
          'instance-id' => 'asd-1234',
          'instance-type' => 't2.nano',
          'kernel-id' => '',
          'local-hostname' => 'ip-10-251-50-12.ec2.internal',
          'local-ipv4' => '',
          'mac network/' => '',
          'placement/' => 'boogers',
          'public-hostname' => 'ec2-203-0-113-25.compute-1.amazonaws.com',
          'public-ipv4' => 'adsfasdfasfd',
          'public-keys/' => 'jfakdsjfkdlsajfkldsajflkasjdfklajsdflkajsldkfjalsdfjaklsdjflasjfklasjdfkals',
          'public-keys/0' => 'asdjfkasdjfkasdjflasjdfklsajdlkfjaldkgfjalkdfgjklsdfjgklsdjfklsjlkdfjakdlfjalskdfjlas',
          'reservation-id' => 'r-fea54097',
          'security-groups' => 'groupidygroupgroupgroup',
          'services/' => ''
        }
      end

      # Get or create an EC2 client and cache that client so that a Context is more well tied together
      #
      # Parameters
      # * opts +Hash+ (optional)
      # * * stub_responses - defaulted to +false+ but it can be overriden with the desired responses for local testing
      # * * region - defaulted to use the <tt>#region()</tt> method
      # * * AWS::Credentials object, which will also scour the context and environment for your keys
      #
      # Returns
      # <tt>AWS::EC2::Client</tt>
      #
      # Example
      #   ec2(Smash::CloudPowers::AwsStubs.node_stub) # sets and gets an <tt>EC2::Client</tt> that is stubbed with the return data in the config <tt>Hash</tt>
      #
      #   images = ec2.describe_images
      #   images.first[:image_id]
      #   # => 'asdf'
      #
      # Notes
      # * defaults can't be overriden or don't have good support for
      #   for it yet but you can use this hash as a guide
      #   for your own custom configuration
      def self.node_stub(opts = {})
        {
          stub_responses: {
            create_tags: {},
            run_instances: {
              instances: [
                { instance_id: 'asd-1234', launch_time: Time.now, state: { name: 'running' } },
                { instance_id: 'qwe-4323', launch_time: Time.now, state: { name: 'running' } },
                { instance_id: 'tee-4322', launch_time: Time.now, state: { name: 'running' } },
                { instance_id: 'bbf-6969', launch_time: Time.now, state: { name: 'running' } },
                { instance_id: 'lkj-0987', launch_time: Time.now, state: { name: 'running' } },
            ]},
            describe_instances: {
              reservations: [
                { instances: [
                  { instance_id: 'asd-1234', state: { code: 200, name: 'running' } },
                  { instance_id: 'qwe-4323', state: { code: 200, name: 'running' } },
                  { instance_id: 'tee-4322', state: { code: 200, name: 'running' } },
                  { instance_id: 'bbf-6969', state: { code: 200, name: 'running' } },
                  { instance_id: 'lkj-0987', state: { code: 200, name: 'running' } }
            ] }] },
            describe_images: {
              images: [
                { image_id: 'asdf', state: 'available' },
                { image_id: 'fdas', state: 'available' },
                { image_id: 'fdadg', state: 'available' },
                { image_id: 'aswre', state: 'available' },
                { image_id: 'fsnkv', state: 'available' },
              ]
            }
          }
        }
      end

      # Stub data for a SNS client
      #
      # Parameters
      # * opts +Hash+
      # * * stub_responses: defaulted to false but it can be overriden with the desired responses for local testing
      # * * region: defaulted to use the `#region()` method
      # * * AWS::Credentials object, which will also scour the context and environment for your keys
      #
      # Returns
      # AWS::SNS client
      #
      # Example
      #   sns(Smash::CloudPowers::AwsStubs.broadcast_stub) # sets and gets an Kinesis client
      #
      #   create_channel!('testBroadcast')
      #   # => true
      #
      # Notes
      # * defaults can't be overriden or don't have good support for
      #   for it yet but you can use this hash as a guide
      #   for your own custom configuration
      def self.broadcast_stub(opts = {})
        arn = "arn:aws:sns:us-west-2:8123456789:#{opts[:name] || 'testChannel'}"
       stub = {
          stub_responses: {
            create_topic: { topic_arn: arn },
            delete_topic: {},
            list_topics: { topics: [{ topic_arn: arn }], next_token: '1234asdf' },
            publish: { message_id: 'msgidmsgidmsgidmsgid' },
            subscribe: { subscription_arn: 'subarnsubarnsubarn' }
          }
        }
        stub.merge(opts.select { |k,v| stub.key? k })
      end

      # Get or create an Kinesis client and cache that client so that a Context is more well tied together
      # Parameters
      # * opts <tt>Hash</tt>
      # * * stub_responses: defaulted to false but it can be overriden with the desired responses for local testing
      # * * region: defaulted to use the `#region()` method
      # * * AWS::Credentials object, which will also scour the context and environment for your keys
      #
      # Returns
      # AWS::Kinesis client
      #
      # Example
      #   # sets and gets an Kinesis client.  No need to set a variable because one was
      #   # just created as +@kinesis+ and is set to the client
      #   kinesis(Smash::CloudPowers::AwsStubs.pipe_stub)
      #
      #   pipe_to('somePipe') { update_body(status: 'waHoo') }
      #   # => sequence_number: '1676151970'
      #
      # Notes
      # * defaults can't be overriden or don't have good support for
      #   for it yet but you can use this hash as a guide
      #   for your own custom configuration
      def self.pipe_stub(opts = {})
        stub = {
          stub_responses: {
            create_stream: {},
            put_record: {
              shard_id: opts[:shard_id] || 'idididididididid',
              sequence_number: opts[:sequence_number] || '1676151970'
            },
            describe_stream: {
              stream_description: {
                stream_name: opts[:name] || 'testPipe',
                stream_arn:  'arnarnarnarnar',
                stream_status: 'ACTIVE',
                shards: [
                  { shard_id: '1',
                    parent_shard_id: 'wowza',
                    hash_key_range: {
                      starting_hash_key: 'starting',
                      ending_hash_key: 'ending'
                    },
                    sequence_number_range: {
                      starting_sequence_number: '1'
                    }
                  }
                ],
                has_more_shards: true,
                retention_period_hours: 1,
                enhanced_monitoring: []
              }
            }
          }
        }
        stub.merge(opts.select { |k| stub.key?(k) })
      end

      # Get or create an S3 client and cache that client so that a Context is more well tied together
      #
      # Parameters
      # * opts <tt>Hash</tt>
      # * * stub_responses: defaulted to false but it can be overriden with the desired responses for local testing
      # * * region: defaulted to use the `#region()` method
      # * * AWS::Credentials object, which will also scour the context and environment for your keys
      #
      # Returns
      # AWS::S3 client
      #
      # Example
      #   s3(Smash::CloudPowers::AwsStubs.storage_stub)
      #   expect(s3.head_bucket).to be_empty
      #   # passing expectation
      #
      # Notes
      # * defaults can't be overriden or don't have good support for
      #   for it yet but you can use this hash as a guide
      #   for your own custom configuration
      def self.storage_stub(opts = {})
        {
          stub_responses: {
            head_bucket: {}
          }
        }
      end

      # Stub data for an SQS client
      #
      # Parameters
      # * opts +Hash+ (optional)
      # * * +:stub_responses+ - defaulted to false but it can be overriden with the desired responses for local testing
      # * * +:region+ - defaulted to use the +#region()+ method
      # * * +AWS::Credentials+ object, which will also scour the context and environment for your keys
      #
      # Returns
      # AWS::SQS client
      #
      # Example
      #   sqs(Smash::CloudPowers::AwsStubs.queue_stub(name: 'someQueue'))
      #   create_queue('someQueue') # uses AWS::SQS
      #   # => 'https://sqs.us-west-2.amazonaws.com/12345678/someQueue'
      #
      # Notes
      # * defaults can't be overriden or don't have good support for
      #   for it yet but you can use this hash as a guide
      #   for your own custom configuration
      def self.queue_stub(opts = {})
        {
          stub_responses: {
            create_queue: {
              queue_url: "https://sqs.us-west-2.amazonaws.com/12345678/#{opts[:name] || 'testQueue'}"
            },
            delete_message: {}, # #delete_message() returns nothing
            delete_queue: {}, # #delete_queue() returns nothing
            get_queue_attributes: {
              attributes: { 'ApproximateNumberOfMessages' => rand(1..10).to_s }
            },
            get_queue_url: {
              queue_url: "https://sqs.us-west-2.amazonaws.com/12345678/#{opts[:name] || 'testQueue'}"
            },
            list_queues: {
              queue_urls: ["https://sqs.us-west-2.amazonaws.com/12345678/#{opts[:name] || 'testQueue'}"]
            },
            receive_message: {
              messages: [
                {
                  attributes: {
                    "ApproximateFirstReceiveTimestamp" => "1442428276921",
                    "ApproximateReceiveCount" => "5",
                    "SenderId" => "AIDAIAZKMSNQ7TEXAMPLE",
                    "SentTimestamp" => "1442428276921"
                  },
                  body: "{\"foo\":\"bar\"}",
                  md5_of_body: "51b0a325...39163aa0",
                  md5_of_message_attributes: "00484c68...59e48f06",
                  message_attributes: {
                    "City" => {
                      data_type: "String",
                      string_value: "Any City"
                    },
                    "PostalCode" => {
                      data_type: "String",
                      string_value: "ABC123"
                    }
                  },
                  message_id: "da68f62c-0c07-4bee-bf5f-7e856EXAMPLE",
                  receipt_handle: "AQEBzbVv...fqNzFw=="
                }
              ]
            },
            send_message: {
              md5_of_message_attributes: "00484c68...59e48f06",
              md5_of_message_body: "51b0a325...39163aa0",
              message_id: "da68f62c-0c07-4bee-bf5f-7e856EXAMPLE"
            }
          }
        }.merge(opts)
      end
    end
  end
end
