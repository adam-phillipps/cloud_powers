{<img src="https://badge.fury.io/rb/cloud_powers.svg" alt="Gem Version" />}[https://badge.fury.io/rb/cloud_powers]# CloudPowers

## Description

CloudPowers is a wrapper around certain AWS services.  It was developed with the _need_ instead of the _resource_ in mind so even though AWS is the only service provider included now, it shouldn't be the only one forever.  There are several pieces of the Cloud Power module to talk about:
* SelfAwareness: Gathers data about "self"
* Synapse: Handles communication needs
* Delegator: dynamically include Ruby executables from S3
and more...

* Each module in Cloud Powers is in charge of a specific type of task that helps bring projects together and communicate with the outside world.

Below is a breakdown of the installation, common services provided and an example or 2 of popular methods.
_Better docs are on the way_

## Installation

Add this line to your application's Gemfile:

```Ruby
gem 'cloud_powers'
```

then execute:

    $ bundle

Or install it yourself as:

    $ gem install cloud_powers

then either:
    * set environment variables that matches the below group
    * fill out a .env file and load it from the class that is using CloudPowers, like this
    Notes:
      * The code does its best in many cases to make a good guess at some of the configuration
        for you but if you set them in your system environment variables or in the .env file,
        it'll have a much better
```Ruby
require 'dotenv'
Dotenv.load('path to your .env file')
```
_things you need for pre-v1_:
```Ruby
# Aws access:
AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""

# Aws areas and auth-related locations:
AWS_REGION=""

# Aws Build info:
AMI_NAME="for Cerebrums to create a node"

# Aws kinesis stream names
STATUS_STREAM="e.g. kinesis stream name"

# Aws s3 buckets etc
TASK_STORAGE="e.g. s3 object name"

# Aws sqs queue addresses
BACKLOG_QUEUE_ADDRESS=""
WIP_QUEUE_ADDRESS=""
FINISHED_QUEUE_ADDRESS=""
```

## Usage

### AwsResource
    * AWS resources that should be used by many services, e.g. Delegator _on EC2_ uses S3, EC2 and SQS to gain knowledge about the
    context it will be working in.


### Delegator
  * Helps a node figure out what task it should be running, where its executables are, gathers it/them and loads them.
  * Lives in the Job and Task instantiation chain


### Helper
  * useful shared methods, like one that turns a string into snake_case


### SelfAwareness
  * gets and sets info about the instance -> Neuron/Cerebrum/etc)
```Ruby
    get_awareness!
```
  * retrieves and sets all metadata from the EC2 instance and a few other things like the instance hostname (can find the instance IP from here).
  * See EC2 metadata for details on the instance/node metadata that is set.
  * Additionally, the instance public hostname, id and a few others are set using other-than-EC2-metadata methods.


### SmashError


### Storage
  * S3


### Synapse
  * A Synapse is used for communicating, usually between nodes and an external source for status updates but the Synapse can handle any kind of information that needs to be passed.
  * Architecture
    * The Synapse is a communications module that is broken up into separate types of communication, for separate needs.
    * There are 2 modules, soon to be 3, inside the Synapse module:

  #### Queue
    * like a task list or a message board for asynchronous communication
    * Board <Struct>:
      * interface with Queue config, data, name, etc.
      ```Ruby
        default_workflow = Workflow.new
        board = Board.new(default_workflow)
        board.name
        => 'backlog'
        board.address
        => 'http://aws-url/backlog-board-url'
        board.next_board # useful because this is a simple state-machine implementation
        => 'wip'
      ```
    Example usage:
      1. Give the entire stream name or a symbol or string that is found in the .env for the name of the Queue
      2. provide a block that will create the record that gets sent to the board
    ```Ruby
      poll(board_name <string|symbol>, opts <optional config Hash>) { block }
    ```
    or
    ```Ruby
      poll(:backlog) { |msg, stats| Task.new(instance_id, msg) if stats.success? }
    ```
    or
    ```Ruby
      poll(:backlog, wait_time: 30, delete: false) do
        edited_message = sitrep.merge(foo: 'bar')
        update = some_method(edited_message)
      end
    ```
  #### Pipe
    * Good for real time information passing, like status updates, results reporting, operations, etc.
    * The Pipe module is for communicating via streams.  Piping is meant to be a way to communicate status, problems and  other general info or huge result sets and things of that nature.  There can be very high traffic through the pipe or none at all.  Very soon (probably V-0.2.6 or 7), Cerebrums will be data consumers, to the Java KCL and MultiLangDaemon level, so keeping messages straight is done via partition ID.  The partition ID of any message is to identify which node the message is about or the "batch" or "group" or any other concept like that. So the instance ID is used in nodes like the Neuron and Cerebrum and other identifiers that are deemed best are used in other projects as a batch ID.

    Example usage:
    ```Ruby
      pipe_to(stream_name <string/symbol>) { &block }
    ```
    ```Ruby
      pipe_to(:status_queue) { sitrep(content: 'workflowComplete') }
    ```
    and for multiple records (KCL)
    ```Ruby
      flow_to(stream_name <string/symbol>) { &block }
    ```
    ```Ruby
      flow_to(:status_queue) do
        interesting_instances = neurons.map do |neuron|
          return neuron if neuron.workflow.done?
        end
        find_efficient_neurons(interesting_instances) # this gets sent through the Pipe
      end
    ```


  #### Memory
    * Allows the nodes to have a collective awareness of each other, the environment they work in and other Jobs (Coming soon...)


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/adam-phillipps/cloud_powers.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

