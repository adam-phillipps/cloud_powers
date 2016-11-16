module Smash
  module CloudPowers
    module Synapse
      module Queue
        # The Queue::Resource class helps wrap up information and functionality of a Queue on SQS.
        # It is basically just an abstraction to make using SQS simpler
        class Resource
          extend Smash::CloudPowers::Creatable
          include Smash::CloudPowers::AwsResources
          include Smash::CloudPowers::Synapse::Queue
          include Smash::CloudPowers::Helper
          include Smash::CloudPowers::Zenv

          # The URL the Aws::SQS::Queue uses
          attr_accessor :address
          # The name the Aws::SQS::Queue uses
          attr_accessor :name
          # Same as <tt>@name</tt> except '_queue' is appended.  This is useful
          # for other objects that use this class, so they can gain an easy means
          # to name this, uniquely from other resource(s) with similar name(s)
          attr_accessor :full_name
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
            @sqs = client
            @name = name
            @full_name = queue_name(@name)
          end

          # Gives the Queue address (URL).  First the environment is searched, using Zenv and if nothing is
          # found, the best guess attempt at the correct address is used.
          #
          # Returns
          #   * queue address <String>
          def address
            zfind(@name) || best_guess_address
          end

          # Gives a best guess at the URL that points toward this Resource's Queue.  It uses a couple params
          # to build a standard URL for SQS.  The only problem with using this last resort is you may need
          # to use a Queue from a different region, account or name but it can be a handy catch-all for the URLs
          # for most cases.
          #
          # Returns String
          # * exp. "https://sqs.us-west-2.amazonaws.com/12345678/fooBar"
          def best_guess_address
            "https://sqs.#{zfind(:aws_region)}.amazonaws.com/#{zfind(:account_number)}/#{@name}"
          end

          # Creates an actual Queue in SQS using the standard format for <b><i>this</i></b> queue name (camel case)
          #
          # Returns
          # +Queue::Resource+
          def create_resource
            begin
              sqs.create_queue(queue_name: to_camel(@name))
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
            @poller ||= Aws::SQS::QueuePoller.new(address)
          end

          # Retrieves a message from the Queue and deletes it from the Queue in SQS
          def pluck_message
            pluck_queue_message(@name)
          end

          # This method creates the queue in SQS for the given Resource instance
          # It can be coupled with the #build() method in order to use a queue without
          # making the call to create it on AWS
          #
          # Example
          #   resource = Resource.build('example')
          #   resource.exists?
          #   # => false
          #   resource.save!
          #   resource.exists?
          #   # => true
          def save!
            create_queue!
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
