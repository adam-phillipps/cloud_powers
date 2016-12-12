require 'cloud_powers/aws_resources'
require 'cloud_powers/helpers'
require 'cloud_powers/resource'
require 'cloud_powers/synapse/queue'
require 'cloud_powers/zenv'

module Smash
  module CloudPowers
    module Synapse
      module Queue
        # The Queue::Resource class helps wrap up information and functionality of a Queue on SQS.
        # It is basically just an abstraction to make using SQS simpler
        class Poller < Smash::CloudPowers::Resource
          attr_accessor :sqs

          def initialize(name:, client: sqs, **config)
            super
            @sqs = client
            @call_name = queue_poller_name(name)
          end

          def create_resource
            @response = queue_poller(queue_url: address, client: sqs)
          end
        end
      end
    end
  end
end
