# require 'auth'
# require 'aws_resources'
require 'json'
require_relative 'helper'
require_relative 'storage'

module Smash
  module CloudPowers
    module Delegator
      extend Smash::CloudPowers::Auth
      include Smash::CloudPowers::AwsResources
      include Smash::CloudPowers::Helper
      include Smash::CloudPowers::Storage

      def build(id, msg)
        body = JSON.parse(msg.body)
        begin
          task = body.delete('task')
          if approved_task? task
            source_task(task)
            require_relative task_require_path(task)
            Smash.const_get(to_pascal(task)).new(id, msg)
          else
            Smash::Task.new(id, msg) # returns a default Task
          end
        rescue JSON::ParserError => e
          message = [msg.body, format_error_message(e)].join("\n")
          logger.info "Message in backlog is ill-formatted: #{message}"
          pipe_to(:status_stream) { sitrep(extraInfo: { message: message }) }
        end
      end

      def approved_task?(name = nil)
        # TODO: improve this
        ['demo', 'testinz'].include? to_snake(name)
      end
    end
  end
end
