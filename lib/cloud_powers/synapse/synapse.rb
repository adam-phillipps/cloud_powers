require_relative './broadcast/broadcast'
require_relative './queue/board'
require_relative './queue/queue'
require_relative './pipe/pipe'

module Smash
  module CloudPowers
    # The Synapse module provides all communications functionality
    # - Broadcast is a module that is useful for sending 1 message to multiple recipients
    # - Pipe is a module that is useful for sending large result sets, data to be processed
    #     or loaded, logging info and any other high-throughput/data-centric application with
    # - Queue is a module that is primarily used for asynchronous communications between a sender
    #     and any number of users or apps that _might_ need to use it
    module Synapse
      include Smash::CloudPowers::Synapse::Broadcast
      include Smash::CloudPowers::Synapse::Pipe
      include Smash::CloudPowers::Synapse::Queue
    end
  end
end
