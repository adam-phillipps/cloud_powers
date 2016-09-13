require_relative 'helper'
require 'byebug'

module Smash

  module Delegator
    include CloudPowers::Helper

    def build(id, msg)
      begin
        possible_type = JSON.parse(msg.body).delete('task')
        type = to_camal(possible_type)
        if approved_task? type
          # TODO: get file from Storage
          require_relative "../tasks/#{possible_type.downcase}"
          Smash.const_get(type).new(id, msg)
        else
          Task.new(id, msg)
        end
      rescue JSON::ParserError => e
        message = [msg.body, format_error_message(e)].join("\n")
        logger.info "Message in backlog is ill-formatted: #{message}"

        pipe_to(:status_stream) do
          {
            type: 'SitRep',
            content: 'taskError',
            extraInfo: { message: message }
          }
        end
      end
    end

    def approved_task?(type = nil)
      # TODO: improve this
      ['Demo'].include? type
    end
  end
end
