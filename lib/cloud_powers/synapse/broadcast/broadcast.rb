module Smash
  module CloudPowers
    module Synapse
      module Broadcast
        include Smash::CloudPowers::Helper
        include Smash::CloudPowers::AwsResources
        include Smash::CloudPowers::Zenv

        # A simple Struct to bind the name with the arn of the topic
        Channel = Struct.new(:set_name, :set_arn, :set_endpoint) do
          include Smash::CloudPowers::Zenv

          def arn
            set_arn || "arn:aws:sns:#{zfind(:region)}:#{zfind(:accound_number)}:#{set_name}"
          end

          def name
            set_name || set_arn.split(':').last
          end
        end # end Channel
        #################

        # Creates a Channel that references this AWS SNS topic that can be used to announce and
        # group messages
        # @params: name <String>: the name of the channel
        def create_channel!(name)
          resp = sns.create_topic(name: name)
          Channel.new(nil, resp.topic_arn)
        end

        # Deletes a topic from SNS-land
        # @params: channel <Broadcast::Channel>
        def delete_channel!(channel)
          sns.delete_topic(topic_arn: channel.arn)
        end

        # Creates a connection to the Broadcast so that new messages will be picked up
        # @params: channel <Broadcast::Channel>
        def listen_on(channel)
          sns.subscribe(
            topic_arn:    channel.arn,
            protocol:     'application',
            endpoint:     channel.endpoint
          )
        end

        # Lists the created topics in SNS.
        # @returns results <Array
        def real_channels
          results = []
          next_token = ''
          loop do
            resp = sns.list_topics((next_token.empty? ? {} : { next_token: next_token }))
            results.concat(resp.topics.map(&:topic_arn))
            next_token = (resp.next_token.empty? ? '' : resp.next_token)
            break if next_token == ''
          end
          results
        end

        # Sends a message to the channel
        # @params: [opts <Hash>]: can configure the parameters for the SNS#publish call
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
