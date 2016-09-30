require_relative './broadcast/broadcast'
require_relative './queue/board'
require_relative './queue/queue'
require_relative './pipe/pipe'

module Smash
  module CloudPowers
    # This is the "Parent" module for all the communication in cloud powers
    # Broadcast is good for transmitting a message 1 time to many recipients
    # Pipe is good for logging, submitting and consuming large results or any
    #   other high throughput application
    # Queue is an unordered collection of messages that can be stored for a
    #   relatively long period of time that multiple consumers can poll
    module Synapse
      include Smash::CloudPowers::Synapse::Broadcast
      include Smash::CloudPowers::Synapse::Pipe
      include Smash::CloudPowers::Synapse::Queue
    end
  end
end
