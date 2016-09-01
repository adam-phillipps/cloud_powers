require 'dotenv'
Dotenv.load('.cerebrum.env')
require_relative 'auth'
require_relative 'self_awareness'
require_relative 'synapse'

module Smash
  class Cerebrum
    include Smash::CloudPowers::Auth
    include Smash::CloudPowers::SelfAwareness
    include Smash::CloudPowers::Synapse

    def initialize
      Smash::CloudPowers::SelfAwareness.get!
      @status_thread = Thread.new { send_frequent_status_updates(interval: 15) }
    end

    def backlog_poller_config(opts = {})
      {
        idle_timeout: 60,
        wait_time_seconds: nil,
        max_number_of_messages: 1,
        visibility_timeout: 10
      }.merge(opts)
    end
  end
end
