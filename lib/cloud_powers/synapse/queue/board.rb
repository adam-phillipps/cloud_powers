module Smash
  module CloudPowers
    module Synapse
      module Queue
        # The Queue::Board class helps wrap up information and functionality of a Queue on SQS.
        # It is basically just an abstraction to make using SQS simpler
        class Board
          include Smash::CloudPowers::AwsResources
          include Smash::CloudPowers::Synapse::Queue
          include Smash::CloudPowers::Helper
          include Smash::CloudPowers::Zenv

          attr_accessor :address, :name, :poller

          # Takes a `name` and creates a Board object.
          # The #new method is wrapped in #build() and #create!() but isn't labeled private so
          # #new can be used instead of build.
          # The Board doesn't create Queue(s) or any other API calls until it is instructed to.
          # @params: name <String>: the name of the board can be used to find its arn/url etc
          # @returns: Queue::Board
          # not.new
          def initialize(name)
            @name = name
          end

          # Gives back a string representation of the instance variable for this board.
          # @returns: instance_variable <String>: the instance variable for this Board in string format
          # Example:
          #   board = Board.new(:backlog)
          #   Smash.instance_variable_get(board.i_var)
          #   #=> Board <name: :backlog ...>
          def i_var
            "@#{@name}"
          end

          # Gives the Queue address (URL).  First the environment is searched, using Zenv and if nothing is
          # found, the best guess attempt at the correct address is used.
          # @returns: queue address <String>
          def address
            zfind(@name) ||  best_guess_address
          end

          # Gives a best guess at the URL that points toward this Board's Queue.  It uses a couple params
          # to build a standard URL for SQS.  The only problem with using this last resort is you may need
          # to use a Queue from a different region, account or name but it can be a handy catch-all for the URLs
          # for most cases.
          def best_guess_address
            "https://sqs.#{zfind(:aws_region)}.amazonaws.com/#{zfind(:account_number)}/#{@name}"
          end

          # Builds a Queue::Board object and returns it.  No API calls are sent using this method
          # @params: name <String>
          # @returns: Queue::Board
          def self.build(name)
            new(name)
          end

          # Builds then Creates the Object and makes the API call to SQS to create the queue
          # @params: name <String>
          # @returns: Queue::Board with an actual queue in SQS
          def self.create!(name)
            built_board = build(name)
            built_board.create_queue!
          end

          # Creates an actual Queue in SQS using the standard format for a queue name (camel case)
          # @returns: Queue::Board
          def create_queue!
            sqs.create_queue(queue_name: to_camel(@name))
            self
          end

          # Deletes an actual Queue from SQS
          def destroy!
            sqs.delete_queue(queue_url: address)
          end

          # Predicate method to query SQS for the queue
          def exists?
            queue_exists?(@name)
          end

          # Gets the approximate message count for a Queue using the 'ApproximateMessageCount' attribute
          def message_count
            get_queue_message_count(address)
          end

          # Gets a QueuePoller for the Queue attached to this Board instance
          def poller
            @poller ||= Aws::SQS::QueuePoller.new(address)
          end

          # Retrieves a message from the Queue and deletes it from the Queue in SQS
          def pluck_message
            pluck_queue_message(@name)
          end

          # This method creates the queue in SQS for the given Board instance
          # It can be coupled with the #build() method in order to use a queue without
          # making the call to create it on AWS
          def save!
            create_queue!
          end

          # Sends the given message to the queue
          # @params: message, which is either used as JSON or converted into it
          def send_message(message)
            send_queue_message(
              address, (valid_json?(message) ? message : message.to_json)
            )
          end
        end
      end
    end
  end
end
