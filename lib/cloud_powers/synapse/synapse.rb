require_relative './broadcast/broadcast'
require_relative './queue/board'
require_relative './queue/queue'
require_relative './pipe/pipe'
require_relative './websocket/websocserver'
require_relative './websocket/websocclient'

module Smash
  module CloudPowers
    # The Synapse module provides all communications functionality
    module Synapse
      # Broadcast is a module that is useful for sending 1 message to multiple recipients
      include Smash::CloudPowers::Synapse::Broadcast
      # Pipe is a module that is useful for sending large result sets, data to be processed
      # or loaded, logging info and any other high-throughput/data-centric application with
      include Smash::CloudPowers::Synapse::Pipe
      # Queue is a module that is primarily used for asynchronous communications between a sender
      # and any number of users or apps that _might_ need to use it
      include Smash::CloudPowers::Synapse::Queue
      # WebSocClient ..._Faisal's turn_...
      include Smash::CloudPowers::Synapse::WebSocClient
      # WebSocServer ..._Faisal's turn_...
      include Smash::CloudPowers::Synapse::WebSocServer
    end
  end
end
