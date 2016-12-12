require 'json'
require 'cloud_powers/auth'
require 'cloud_powers/aws_resources'
require 'cloud_powers/helpers'
require 'cloud_powers/storage'

module Smash
  module BrainFunc
    # The Delegator module is a way to dynamically source and use
    # Ruby source code.  You pass a message or something that can
    # respond to +#body()+ and give back a String.  The String should
    # be the name of the class you're trying to instantiate and use
    module Delegator
      extend Smash::CloudPowers::Auth
      include Smash::CloudPowers::AwsResources
      include Smash::CloudPowers::Helpers
      include Smash::CloudPowers::Storage

      # Predicate method to return true for valid job titles and false for invalid ones
      #
      # Parameters
      # * name +String+ (optional) - name of the job in snake_case
      #
      # Returns
      # +Boolean+
      #
      # Notes
      # * TODO: needs improvement
      def approved_job?(name = nil)
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
      #   # the message responds to +#body()+ with "Examplejob"
      #   job.build('abc-1234', Aws::SQS::Message)
      #   # => +Examplejob:Object+
      def build_job(id, msg)
        body = decipher_delegator_message(msg)

        begin
          job = body['job']
          if approved_job? job
            source_job(job)
            require_relative job_require_path(job)
            create_resource_from(job, body)
          else
            Smash::Job.new(id, body) # returns a default job
          end
        rescue JSON::ParserError => e
          message = [msg.body, format_error_message(e)].join("\n")
          logger.info "Message in backlog is ill-formatted: #{message}"
          pipe_to(:status_stream) { sitrep(extraInfo: { message: message }) }
        end
      end

      # Create any Constant
      def create_resource_from(name, config = {})
        config = modify_keys_with(config) { |k| k.to_sym }
        Smash.const_get(to_pascal(name)).create!(name: name, **config)
      end

      # Get the body of the message out from a few different types of objects.
      # The idea is to allow JSON, a String or some object that responds to :body
      # through while continually attempting to decipher other types of objects
      # finally giving up.  But wait, after it gives up, it just turns it into a
      # Hash and assumes that the value is a job name.
      #
      # Parameters
      # * msg +String+
      #
      # Returns
      # +Hash+
      #
      # Example
      #   # given hash_message = { job: 'example' }
      #   # givem json_message = "\{"job":"example"\}"
      #   # given message_with_body = <Object @body="stuff stuff stuff">
      #
      #   decipher_delegator_message(hash_message)
      #   # => { job: 'example' }
      #   decipher_delegator_message(json_message)
      #   # => { job: 'example' }
      #   decipher_delegator_message(message_with_body)
      #   # => { job: 'example' }
      #   decipher_delegator_message('some ridiculous string')
      #   # => { job: 'some_ridiculous_string'}
      #
      # Notes
      # See +#to_snake()+
      def decipher_delegator_message(msg)
        begin
          if msg.respond_to? :body
            decipher_delegator_message(msg.body)
          else
            msg.kind_of?(Hash) ? msg : from_json(msg)
          end
        rescue Exception
          { job: to_snake(msg.to_s) }
        end
      end
    end
  end
end
