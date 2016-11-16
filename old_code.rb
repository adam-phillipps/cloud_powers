QUEUE
# Builds a Queue::Board object and returns it.  No API calls are sent using this method. This is
# handy if you need to use a Queue but you don't want to create any resources in AWS.
#
# Parameters name +String+
#
# Returns Queue::Board
#
# Example
#   exp_board = Board.build('exampleBoard')
#   puts exp_board.best_guess_address
#   # => 'https://sqs.us-west-2.amaz.....'
def self.build(name, this_sqs = nil)
  new(name, this_sqs)
end

# Builds then Creates the Object and makes the API call to SQS to create the queue
#
# Parameters
# * name <String>
#
# Returns
# +Queue::Board+ with an actual Queue in SQS
#
# Example
#   exp_board = Board.create!('exampleBoard')
#   queue_search(exp_board.name)
  self.build(name, this_sqs).create_queue!
end

# Creates an actual Queue in SQS using the standard format for <b><i>this</i></b> queue name (camel case)
#
# Returns
# +Queue::Board+
def create_queue!
  begin
    sqs.create_queue(queue_name: to_camel(@name))
    self
  rescue Aws::SQS::Errors::QueueDeletedRecently
    sleep 5
    retry
  end
end

# Example
#   board = Board.build('example')
#   board.exists?
#   # => false
#   board.save!
#   board.exists?
#   # => true
def save!
  create_queue!
end

NODE
# Factory method for creating a +Node+ resource
#
# Parameters
# * opts +Hash+
#
# Returns
# <tt>Smash::CloudPowers::NodeResource</tt>
def create_resource(**opts)
  # deal with i-var creation, existance checking, etc
  Smash::CloudPowers::NodeResource.create(opts)
end

def create_nodes(opts = {}, tags = [])
  ids = nil
  begin

    response = ec2.run_instances(node_config(opts))
    ids = response.instances.map(&:instance_id)

    if should_wait
      count = 0
      begin
        ec2.wait_until(:instance_running, instance_ids: ids) do
          logger.info "waiting for #{ids.count} Neurons to start..."
        end
      rescue Aws::Waiters::Errors::WaiterFailed => e
        # TODO: deal with failed instances
        # redo unless (count += 1 <=3 )
      end
    end

    batch_tag(ids, tags) unless tags.empty?
    ids

  rescue Aws::EC2::Errors::DryRunOperation
    ids = (1..(opts[:max_count] || 0)).to_a.map { |n| n.to_s }
    logger.info "waiting for #{ids.count} Neurons to start..."
  end

  ids
end

