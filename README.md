################################################################################
# Cloud Powers
################################################################################

## Description
CloudPowers is a wrapper around AWS and other cloud services.  Below is a
  breakdown of the common services provided and an example or 2 of popular methods.

## SelfAwareness: (set/get info about the instance -> Neuron/Cerebrum/etc)
  * get_awareness!
    * retrieves and sets all metadata from the EC2 instance and a few other things
      like the instance hostname (can find the instance IP from here).
      [EC2 Metadata]http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html
## Synapse:
### Pipe: (Streams)
  * pipe_to(stream_name <string/symbol>) { &block }
    * give the entire stream name or a symbol or string that is found in the .env
      for the name of the stream
    * provide a block that will create the record that gets sent on the stream
    ```Ruby
    pipe_to(:status_queue) { update_block_that_returns_data }
    ```
  * flow_to(stream_name <string/symbol>) { &block }
    * follow the pipe_to instructions but you can send multiple records with this
    ```Ruby
    flow_to(:status_queue) do
      interesting_instances = neurons.map do |neuron|
        neuron.get_useful_info.include? 'something'
      end
      block_that_returns_many_records(interesting_instances) # this gets sent
    end
    ```
### Queue: (Queues)
  * #### Board <Struct>:
    * interface with board config/data/name/etc.
  * poll(board_name <string/symbol>, opts <optional config Hash>) { &block }
    ```Ruby
    poll(:backlog) { |msg, stats| Task.new(instance_id, msg) if stats.successful? }
    ```
    1. give the entire stream name or a symbol or string that is found in the .env
      for the name of the stream
    2. provide a block that will create the record that gets sent to the board
    ```Ruby
    poll(:backlog, wait_time: 30, delete: false) do 
      edited_message = sitrep.merge(instanceId:'asdf-1234')
      update = some_method(edited_message)
    end
    ```
## Storage: (S3)
## AwsResource: (all types of AWS recourses that should be used by many services)
## Helper: (useful shared methods, like one that turns a string into snake_case)
