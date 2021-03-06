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

          # Prefers the given arn but it can make a best guess if none is given
          #
          # Returns
          # arn +String+ - arn for this resource
          def arn
            set_arn || "arn:aws:sns:#{zfind(:region)}:#{zfind(:accound_number)}:#{set_name}"
          end

          # Prefers the given name but it can parse the arn to find one
          #
          # Returns
          # name +String+ - name for this resource
          def name
            set_name || set_arn.split(':').last
          end
        end # end Channel
        #################

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
        def create_channel!(name)
          resp = sns.create_topic(name: name)
          Channel.new(nil, resp.topic_arn)
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
