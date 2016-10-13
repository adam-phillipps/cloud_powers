# require 'auth'
# require 'aws_resources'
require 'json'
require_relative 'helper'
require_relative 'storage'

module Smash
  module CloudPowers
    # The Delegator module is a way to dynamically source and use
    # Ruby source code.  You pass a message or something that can
    # respond to +#body()+ and give back a String.  The String should
    # be the name of the class you're trying to instantiate and use
    module Delegator
      extend Smash::CloudPowers::Auth
      include Smash::CloudPowaters::AwsResources
      include Smash::CloudPowers::Helper
      include Smash::CloudPowers::Storage

      # responsible for sourcing, loading into the global namespace
      # and use of Ruby source code, through the +#new()+ method on
      # that class
      #
      # Parameters
      # * id +String+ - the instance id of the calling node.  This gets
      #   used in communication tools etc.
      # * msg - Anything that responds to +#body()+ and returns a String
      #   that can be used in the search for the file in your local and S3
      #   bucket locations
      #
      # Returns
      # +Object+ - a newly instantiated object of the class that matches
      # the name retrieved from the +msg+ parameter
      #
      # Example
      #   class Job; include Smash::CloudPowers::Delegator; end
      #   job = Job.new
      #   # the message responds to +#body()+ with "ExampleTask"
      #   job.build('abc-1234', Aws::SQS::Message)
      #   # => +ExampleTask:Object+
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

      # Predicate method to return true for valid job titles and false for invalid ones
      #
      # Parameters
      # * name +String+ (optional) - name of the task in snake_case
      #
      # Returns
      # +Boolean+
      #
      # Notes
      # * TODO: needs improvement
      def approved_task?(name = nil)
        ['demo', 'testinz'].include? to_snake(name)
      end
    end
  end
end
