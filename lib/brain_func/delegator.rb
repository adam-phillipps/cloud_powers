require 'cloud_powers'
require 'json'

module Smash
  module BrainFunc
    # The Delegator module is a way to dynamically source and use
    # Ruby source code.  You pass a message or something that can
    # respond to +#body()+ and give back a String.  The String should
    # be the name of the class you're trying to instantiate and use
    module Delegator
      extend Smash::CloudPowers::Auth
      include Smash::CloudPowers::AwsResources
      include Smash::CloudPowers::Helper
      include Smash::CloudPowers::Storage

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
        ['demo', 'testinz', 'true_roas'].include? to_snake(name)
      end

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
        body = decipher_message(msg)
        begin
          task = body['task']
          if approved_task? task
            source_task(task)
            require_relative task_require_path(task)
            Smash.const_get(to_pascal(task)).public_send :create, id, body
          else
            Smash::Task.new(id, body) # returns a default Task
          end
        rescue JSON::ParserError
          message = [msg.body, format_error_message(e)].join("\n")
          logger.info "Message in backlog is ill-formatted: #{message}"
          pipe_to(:status_stream) { sitrep(extraInfo: { message: message }) }
        end
      end

      # Get the body of the message out from a few different types of objects.
      # The idea is to allow JSON, a String or some object that responds to :body
      # through while continually attempting to decipher other types of objects
      # finally giving up.  But wait, after it gives up, it just turns it into a
      # Hash and assumes that the value is a Task name.
      #
      # Parameters
      # * msg +String+
      #
      # Returns
      # +Hash+
      #
      # Example
      #   # given hash_message = { task: 'example' }
      #   # givem json_message = "\{"task":"example"\}"
      #   # given message_with_body = <Object @body="stuff stuff stuff">
      #
      #   decipher_message(hash_message)
      #   # => { task: 'example' }
      #   decipher_message(json_message)
      #   # => { task: 'example' }
      #   decipher_message(message_with_body)
      #   # => { task: 'example' }
      #   decipher_message('some ridiculous string')
      #   # => { task: 'some_ridiculous_string'}
      #
      # Notes
      # See +#to_snake()+
      def decipher_message(msg)
        begin
          if msg.respond_to? :body
            decipher_message(msg.body)
          else
            msg.kind_of?(Hash) ? msg : JSON.parse(msg)
          end
        rescue Exception
          { task: to_snake(msg.to_s) }
        end
      end
    end
  end
end
