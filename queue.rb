require 'uri'

module Smash
  module CloudPowers
    module Synapse
      module Queue

        Board = Struct.new(:name) do

          def i_var
            "@#{name}"
          end

          def address

            ENV["#{name.upcase}_QUEUE_ADDRESS"]
          end
          # this is a state machine, these are its states and they are strictly
          # enforced, yo.  Other methods should be refactored before this one.
          def next_board
            name == 'backlog' ? 'wip' : 'finished'
          end
        end

        def build_board(name)
          i_var = "@#{name}"
          if instance_variable_defined?(i_var)
            instance_variable_get(i_var)
          else
            Board.new(name)
          end
        end

        def board_name(url)
          if url =~ URI.regexp
            url = URI.parse(url)
            url.path.split('/').last.split('_').last
          else
            env(url)
          end
        end

        def delete_queue_message(queue, opts = {})
          poll(queue, opts) do |msg, stats|
            poller(queue).delete_message(msg)
            throw :stop_polling
          end
        end

        def get_count(board)
          sqs.get_queue_attributes(
            queue_url: board_name(board),
            attribute_names: ['ApproximateNumberOfMessages']
          ).attributes['ApproximateNumberOfMessages'].to_f
        end

        def poll(board, opts = {})
          poller(board).poll(opts) do |msg|
            yield msg if block_given?
          end
        end

        def poller(board_name)
          board = build_board(board_name)

          unless instance_variable_defined?(board.i_var)
            instance_variable_set(
              board.i_var,
              Aws::SQS::QueuePoller.new(board.address)
            )
          end

          instance_variable_get(board.i_var)
        end

        def send_message(board, message)
          sqs.send_message(
            queue_url: env(board),
            message_body: message
          )
        end

        def sqs
          @sqs ||= Aws::SQS::Client.new(credentials: Auth.creds)
        end
      end
    end
  end
end
