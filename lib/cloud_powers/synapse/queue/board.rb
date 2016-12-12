require 'cloud_powers/aws_resources'
require 'cloud_powers/helpers'
require 'cloud_powers/resource'
require 'cloud_powers/synapse/queue'
require 'cloud_powers/zenv'

module Smash
  module CloudPowers
    module Synapse
      module Queue
        # The Queue::Resource class helps wrap up information and functionality of a Queue on SQS.
        # It is basically just an abstraction to make using SQS simpler
        class Board < Smash::CloudPowers::Resource
          include Smash::CloudPowers::AwsResources
          include Smash::CloudPowers::Synapse::Queue
          include Smash::CloudPowers::Helpers
          include Smash::CloudPowers::Zenv

          # The URL the Aws::SQS::Queue uses
          attr_accessor :address
          # +Hash+ response from Aws SDK <tt>Aws::SQS::Client#create_resource()</tt>
          attr_reader :response
          # An Aws::SQS::Client.  See <tt>Smash::CloudPowers::AwsResources#sqs()<tt>
          attr_accessor :sqs

          # Creates a Resource object.
          # The +#new()+ method is wrapped in +#build()+ and +#create!()+ but isn't private so
          # +#new()+ can be used instead of build.
          # The Resource doesn't create Queue(s) or any other API calls until it is instructed to.
          #
          # Parameters
          # * name +String+ - the name of the resource can be used to find its arn/url etc
          #
          # Returns
          # +Queue::Resource+
          def initialize(name:, client: sqs, **config)
            super
            @sqs = client
          end

          # Gives the Queue address (URL).  First the environment is searched, using Zenv and if nothing is
          # found, the best guess attempt at the correct address is used.
          #
          # Returns
          #   * queue address <String>
          def address
            @address ||= best_guess_address(name)
          end

          # Creates an actual Queue in SQS using the standard format for <b><i>this</i></b> queue name (camel case)
          #
          # Returns
          # +Queue::Resource+
          def create_resource
            begin
              @response = sqs.create_queue(queue_name: to_camel(@name))
              yield self if block_given?
              self
            rescue Aws::SQS::Errors::QueueDeletedRecently
              sleep 5
              retry
            end
          end

          # Deletes an actual Queue from SQS
          def destroy!
            sqs.delete_queue(queue_url: address)
          end

          # Gives back a string representation of the instance variable for this resource.
          #
          # Returns +String+ - the instance variable for this Resource in string format
          #
          # Example
          #   queue = Queue::Resource.new(:backlog)
          #   Smash.instance_variable_get(resource.i_var)
          #   #=> Resource <name: :backlog, ...>
          def i_var
            to_i_var(@name)
          end

          # Predicate method to query SQS for the queue
          #
          # Example
          #   queue = Queue::Resource.build('example')
          #   queue.exists?
          #   # => false
          #   queue.save!
          #   queue.exists?
          #   # => true
          def exists?
            queue_exists?(@name)
          end

          def link
            if exists?
              urls = queue_search(call_name)

              if urls.size > 1
                logger.info sitrep(content: "multiple matching #{name} queues to link to")
                return @linked = false
              end

              # @url = urls.first
              @url = sqs.get_queue_url(queue_name: @name).queue_url
            else
              save!
            end
            @linked = @url.eql? urls.first
          end

          # Gets the approximate message count for a Queue using the 'ApproximateMessageCount' attribute
          #
          # Returns
          # +Integer+
          def message_count
            get_queue_message_count(address)
          end

          # Gets a QueuePoller for the Queue attached to this Resource instance.
          #
          # Returns
          # +Aws::SQS::QueuePoller+
          #
          # Notes
          # * Provide an existing SQS Client if one exists.  This is used to sort out development
          # production work.
          def poller
            @poller ||= Aws::SQS::QueuePoller.new(queue_url: address, client: sqs)
          end

          # Retrieves a message from the Queue and deletes it from the Queue in SQS
          def pluck_message
            pluck_queue_message(name)
          end

          # Sends the given message to the queue
          #
          # Parameters
          # * message - used as JSON or converted into it
          def send_message(message)
            send_queue_message(
              address, (valid_json?(message) ? message : message.to_json), sqs
            )
          end
        end
      end
    end
  end
end
