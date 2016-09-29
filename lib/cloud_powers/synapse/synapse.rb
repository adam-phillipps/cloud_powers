require_relative './broadcast/broadcast'
require_relative './queue/board'
require_relative './queue/queue'
require_relative './pipe/pipe'

module Smash
  module CloudPowers
    module Synapse
      include Smash::CloudPowers::Synapse::Broadcast
      include Smash::CloudPowers::Synapse::Pipe
      include Smash::CloudPowers::Synapse::Queue
    end
  end
end
