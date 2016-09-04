require_relative 'helper'
require 'byebug'

module Smash
  include CloudPowers::Helper

  module Delegator
    def build_job(id, msg)
      begin
        type = JSON.parse(msg.body).delete(:job_type)
        if approved_task? type
          eval("#{type}.new(id, msg)")
        else
          DefaultTask.new(id, msg)
        end
      rescue JSON::ParserError => e
        message = [msg.body, format_error_message(e)].join("\n")
        logger.info "Message in backlog is ill-formatted: #{message}"

        pipe_to(:status_stream) do
          {
            type: 'SitRep',
            content: 'task-error',
            extraInfo: { message: message }
          }
        end
      end
    end

    def approved_task?(type = nil)
      # TODO:
      # - find a way to verify the validity of the job type.
      #   - this could be a dynamo table or a config file that
      #     gets deployed, etc.
      #   - The info that you need is the name of the job type
      #     - possible convention:
      #         Approved_jobs: {
      #           FredsScraping,
      #           OverstockSales,
      #           etc
      #         }

      false
    end
  end
end
