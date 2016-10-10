require 'uri'
require_relative 'board'

module Smash
  module CloudPowers
    module Synapse
      module Queue
        include Smash::CloudPowers::AwsResources
        include Smash::CloudPowers::Helper

        # A simpl Struct that acts as a Name to URL map
        NUMap = Struct.new(:set_name, :set_url) do
          def name
            set_name || url.split('/').last # Queue names are last in the URL path
          end

          def url
            set_url || Smash::CloudPowers::Queue::Board.new(name).best_guess_address
          end
        end

        # This method can be used to parse a queue name from its address.  It can be handy if you need the name
        # of a queue but you don't want the overhead of creating a Board object.
        # === @params: url String
        # === @returns: String
        # === Example:
        #     ```Ruby
        #      board_name('https://sqs.us-west-53.amazonaws.com/001101010010/fooBar')
        #      => fooBar
        #     ```
        def board_name(url)
          url.to_s.split('/').last
        end

        # This method builds a Queue::Board object for you to use but doesn't
        # invoke the #create! method, so no API call is made to create the queue
        # on SQS.  This can be used if the board already exists.
        # === @params: name <String>: name of the queue you want to interact with
        # === @returns: Queue::Board
        def build_queue(name)
          Smash::CloudPowers::Queue::Board.build(to_camel(name), sqs)
        end

        # This method allows you to create a queue on SQS without explicitly creating a Board object
        # === @params: name <String>: The name of the queue to be created
        # === @returns: Queue::Board
        def create_queue!(name)
          begin
            Smash::CloudPowers::Queue::Board.create!(to_camel(name), sqs)
          rescue Aws::SQS::Errors::QueueDeletedRecently => e
            sleep 5
            retry
          end
        end

        # Deletes a queue message without caring about reading/interacting with the message.
        # This is usually used for progress tracking, ie; a Neuron takes a message from the Backlog, moves it to
        # WIP and deletes it from Backlog.  Then repeats these steps for the remaining States in the Workflow
        # === @params: queue <String>[, opts <Hash>]
        #   queue is the name of the queue to interact with
        #   opts is a configuration hash for the SQS::QueuePoller
        def delete_queue_message(queue, opts = {})
          poll(queue, opts) do |msg, stats|
            poller(queue).delete_message(msg)
            throw :stop_polling
          end
        end

        # This method is used to gain the approximate count of messages in a given queue
        # === @params: board_url <String>: The URL for the board you need to get a count from
        # === @returns: float representation of the count
        def get_queue_message_count(board_url)
          sqs.get_queue_attributes(
            queue_url: board_url,
            attribute_names: ['ApproximateNumberOfMessages']
          ).attributes['ApproximateNumberOfMessages'].to_f
        end

        # === @params: board<String|symbol>: The name of the board
        # === @returns a message and deletes it from its origin
        def pluck_queue_message(board)
          poll(board) do |msg, poller|
            poller.delete_message(msg)
            return valid_json?(msg.body) ? JSON.parse(msg.body) : msg.body
          end
        end

        # Polls the given board with the given options hash and a block that interacts with
        # the message that is retrieved from the queue
        # === @params: board <String>[, opts <Hash>]
        #   * `board` is the name of the queue you want to poll
        #   * `opts` can have any AWS::SQS polling option
        #   * `&block` is the block that is used to interact with the message that was retrieved
        # === @returns the results from the `message` and the `block` that interacts with the message(s)
        def poll(board_name, opts = {})
          this_poller = queue_poller(board_name)
          results = nil
          this_poller.poll(opts) do |msg|
            results = yield msg, this_poller if block_given?
            this_poller.delete_message(msg)
            throw :stop_polling
          end
          results
        end

        # This method can be used to gain a SQS::QueuePoller.  It creates a Board object,
        # the Board then sends the API call to SQS to create the queue and sets an instance
        # variable, using the board's name, to the Board object itself
        # === @params: board_name <String>: name of the Queue you want to gain a QueuePoller for
        # === @returns: @<board_name:Queue::Board>
        def queue_poller(board_name)
          board = Smash::CloudPowers::Queue::Board.create!(board_name, sqs)

          unless instance_variable_defined?(board.i_var)
            instance_variable_set(board.i_var, board)
          end
          instance_variable_get(board.i_var).poller
        end

        # Checks SQS for the existence of this queue using the #queue_search() method
        # === @params: name String
        # === @returns: Boolean
        # === Notes:
        #     * see #queue_search()
        def queue_exists?(name)
          !queue_search(name).empty?
        end

        # Searches for a queue based on the name
        # === @params: name String
        # === @returns: queue_urls [String]
        def queue_search(name)
          sqs.list_queues(queue_name_prefix: name).queue_urls
        end

        # Sends a given message to a given queue
        # === @params: address <String>: address of the queue you want to interact with
        # === @returns: queue_urls <Array<String>> # TODO: verify this.  maybe it was late...
        def send_queue_message(address, message, this_sqs = sqs)
          this_sqs.send_message(queue_url: address, message_body: message)
        end
      end
    end
  end
end
