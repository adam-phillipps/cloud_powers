module Smash
  module CloudPowers
    module Synapse
      module Queue
        class Board
          include Smash::CloudPowers::AwsResources
          include Smash::CloudPowers::Synapse::Queue
          include Smash::CloudPowers::Helper
          include Smash::CloudPowers::Zenv

          attr_accessor :address, :name, :poller

          def initialize(name)
            @name = name
          end

          def i_var
            "@#{@name}"
          end

          def address
            zfind(@name) ||  best_guess_address
          end

          def best_guess_address
            "https://sqs.#{zfind(:aws_region)}.amazonaws.com/#{zfind(:account_number)}/#{@name}"
          end

          def create_queue!
            sqs.create_queue(queue_name: to_camel(@name))
            self
          end

          def destroy!
            sqs.delete_queue(queue_url: address)
          end

          def exists?
            queue_exists?(@name)
          end

          def message_count
            get_queue_message_count(address)
          end

          def next_board
            workflow.next
          end

          def poller
            @poller ||= Aws::SQS::QueuePoller.new(address)
          end

          def pluck_message
            pluck_queue_message(@name)
          end

          def real?
            queue_exists?(@name)
          end

          def save!
            create_queue!
          end

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
