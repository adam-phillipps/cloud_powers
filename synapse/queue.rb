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
            # TODO: figure out why env('bla') doesn't work
            ENV["#{name.upcase}_QUEUE_ADDRESS"]
          end
          # this is a state machine, these are its states and they are strictly
          # enforced, yo.  Other methods should be refactored before this one.
          def next_board
            name == :backlog ? :wip : :finished
          end
        end # end Board

        def board_name(url)
          # TODO: figure out a way to not have this and :name in Board
          # gets the name from the url
          if url =~ URI.regexp
            url = URI.parse(url)
            url.path.split('/').last.split('_').last
          else
            env(url)
          end
        end

        def build_board(name)
          # i_var = "@#{name}"
          # if instance_variable_defined?(i_var)
          #   instance_variable_get(i_var)
          # else
            Board.new(name)
          # end
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
          message = message.to_json unless message.kind_of? String
          sqs.send_message(
            queue_url: board.address,
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
