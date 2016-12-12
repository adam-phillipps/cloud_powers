require 'cloud_powers/synapse/broadcast'
require 'cloud_powers/synapse/queue'
require 'cloud_powers/synapse/pipe'
require 'cloud_powers/synapse/web_soc'

module Smash
  module CloudPowers
    # The Synapse module provides all communications functionality
    module Synapse
      # Broadcast is a module that is useful for sending 1 message to multiple recipients
      include Smash::CloudPowers::Synapse::Broadcast
      # Pipe is a module that is useful for sending large result sets, data to be processed
      # or loaded, logging info and any other high-throughput/data-centric application with
      include Smash::CloudPowers::Synapse::Pipe
      # MessageBoard is a module that is primarily used for asynchronous
      # communications between a sender and any number of users or apps that
      # _might_ need to use it.  Messages on the board aren't ordered.
      include Smash::CloudPowers::Synapse::Queue
      # Socket is a module that allows Nodes to make a direct connection while
      # still allowing others to read messages.  Websockets are used
      include Smash::CloudPowers::Synapse::WebSoc
    end
  end
end
