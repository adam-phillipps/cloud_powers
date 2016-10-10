require 'spec_helper'

require 'spec_helper'

module Smash
  module CloudPowers
    module AwsStubs

      INSTANCE_METADATA_STUB = {
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

      NODE_STUB = {
        stub_responses: {
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
        }
      end
    end
  end
end
