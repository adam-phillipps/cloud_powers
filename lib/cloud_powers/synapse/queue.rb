require 'uri'

module Smash
  module CloudPowers
    module Synapse
      module Queue
        include Smash::CloudPowers::Helper
        include Smash::CloudPowers::AwsResources
        # Board <Struct>
        # This groups common functionality for a queue
        Board = Struct.new(:sqs, :set_name, :set_address, :workflow) do
          include Smash::CloudPowers::Synapse::Queue
          include Smash::CloudPowers::Helper
          include Smash::CloudPowers::Zenv

          def i_var
            "@#{name}"
          end

          def address
            set_address || zfind(set_name) ||
               "https://sqs.us-west-2.amazonaws.com/#{zfind(:account_number)}/#{name}"
          end

          def create_queue!
            sqs.create_queue(queue_name: to_camel(name))
            self
          end

          def destroy!
            sqs.delete_queue(queue_url: address)
          end

          def message_count
            get_queue_message_count(address)
          end

          def name
            set_name || address.split('/').last
          end

          def next_board
            workflow.next
          end

          def pluck_message(board_name = name)
            pluck_queue_message(board_name)
          end

          def real?
            queue_exists?(name)
          end

          def send_message(message)
            send_queue_message(
              address, (valid_json?(message) ? message : message.to_json)
            )
          end
        end # end Board
        #############################################

        def board_name(url)
          url.to_s.split('/').last
        end

        def create_queue!(name)
          begin
            Board.new(sqs, to_camel(name)).create_queue!
          rescue Aws::SQS::Errors::QueueDeletedRecently => e
            sleep 5
            retry
          end
        end

        def build_queue(name)
          Board.new(sqs, to_camel(name))
        end

        def delete_queue_message(queue, opts = {})
          poll(queue, opts) do |msg, stats|
            poller(queue).delete_message(msg)
            throw :stop_polling
          end
        end

        def get_queue_message_count(board_url)
          sqs.get_queue_attributes(
            queue_url: board_url,
            attribute_names: ['ApproximateNumberOfMessages']
          ).attributes['ApproximateNumberOfMessages'].to_f
        end

        # @params: board<String|symbol>: The name of the board
        # @returns a message and deletes it from its origin
        def pluck_queue_message(board)
          poll(board) do |msg, poller|
            poller.delete_message(msg)
            return valid_json?(msg.body) ? JSON.parse(msg.body) : msg.body
          end
        end

        def poll(board, opts = {})
          this_poller = poller(board)
          results = nil
          this_poller.poll(opts) do |msg|
            results = yield msg, this_poller if block_given?
            this_poller.delete_message(msg)
            throw :stop_polling
          end
          results
        end

        def poller(board_name)
          board = Board.new(sqs, board_name)

          unless instance_variable_defined?(board.i_var)
            instance_variable_set(
              board.i_var,
              Aws::SQS::QueuePoller.new(board.address)
            )
          end
          instance_variable_get(board.i_var)
        end

        def queue_exists?(name)
          !sqs.list_queues(queue_name_prefix: name).queue_urls.empty?
        end

        def queue_search(name)
          sqs.list_queues(queue_name_prefix: name).queue_urls
        end

        def send_queue_message(address, message)
          sqs.send_message(
            queue_url: address,
            message_body: message
          )
        end
      end
    end
  end
end
