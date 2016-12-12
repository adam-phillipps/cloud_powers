require 'cloud_powers/synapse/broadcast/channel'

module Smash
  module CloudPowers
    module Synapse
      module Broadcast
        include Smash::CloudPowers::Helpers
        include Smash::CloudPowers::AwsResources
        include Smash::CloudPowers::Zenv

        # This method can be used to parse a queue name from its address.
        # It can be handy if you need the name of a queue but you don't want
        # the overhead of creating a QueueResource object.
        #
        # Parameters
        # * url +String+
        #
        # Returns
        # +String+
        #
        # Example
        #   board_name('https://sqs.us-west-53.amazonaws.com/001101010010/fooBar')
        #   => foo_bar_board
        def channel_name(arg)
          base_name = to_snake(arg.to_s.split('/').last)
          %r{_channel$} =~ base_name ? base_name : "#{base_name}_channel"
        end

        # Creates a connection point for 1..N nodes to create a connection with the Broadcast
        # <b>Not Implimented</b>
        #
        # Parameters
        # * channel +String+
        #
        # Notes
        # This method is not implemented yet (V 0.2.7)
        def create_distributor(channel)
          sns.create_application_platform()
        end

        # Creates a point to connect to for information about a given topic
        #
        # Parameters
        # * name +String+ - the name of the Channel/Topic to be created
        #
        # Returns
        # +Broadcast::Channel+ - representing the created channel
        def create_channel(name, **config)
          channel_resource =
            Smash::CloudPowers::Synapse::Broadcast::Channel.create!(
              name: name, client: sns, **config
            )

          self.attr_map(channel_resource.call_name => channel_resource) do |attribute, resource|
            instance_attr_accessor attribute
            resource
          end

          channel_resource
        end

        # Deletes a topic from SNS-land
        #
        # Parameters
        # * channel <Broadcast::Channel>
        def delete_channel!(channel)
          sns.delete_topic(topic_arn: channel.arn)
        end

        # Creates a connection to the Broadcast so that new messages will be picked up
        #
        # Parameters channel <Broadcast::Channel>
        def listen_on(channel)
          sns.subscribe(
            topic_arn:    channel.arn,
            protocol:     'application',
            endpoint:     channel.endpoint
          )
        end

        # Lists the created topics in SNS.
        #
        # Returns results <Array
        def real_channels
          results = []
          next_token = ''
          loop do
            resp = sns.list_topics((next_token.empty? ? {} : { next_token: next_token }))
            results.concat(resp.topics.map(&:topic_arn))
            next_token = (resp.next_token.empty? ? '' : resp.next_token)
            break if next_token.empty?
          end
          results
        end

        # Send a message to a Channel using SNS#publish
        #
        # Parameters
        # * opts +Hash+ - this includes all the keys AWS uses but for now it only has defaults
        #   for topic_arn and the message
        # * * +:topic_arn+ - the ARN for the topic in AWS
        # * * +:message+ - the message that should be broadcasted to whoever is listening on this
        #     Channel (AWS Topic)
        def send_broadcast(opts = {})
          msg = opts.delete(:message) || ""

          package = {
            topic_arn:            "topicARN",
            message:              msg.to_json
          }.merge(opts)

          sns.publish(package)
        end
      end
    end
  end
end
