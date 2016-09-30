module Smash
  module CloudPowers
    module Synapse
      module Broadcast
        include Smash::CloudPowers::Helper
        include Smash::CloudPowers::AwsResources
        include Smash::CloudPowers::Zenv

        # A simple Struct to bind the name with the arn of the topic
        Channel = Struct.new(:set_name, :set_arn) do
          include Smash::CloudPowers::Zenv

          # Prefers the given arn but it can make a best guess if none is given
          def arn
            set_arn || "arn:aws:sns:#{zfind(:region)}:#{zfind(:accound_number)}:#{set_name}"
          end

          # Prefers the given name but it can parse the arn to find one
          def name
            set_name || set_arn.split(':').last
          end
        end # end Channel
        #################

        def create_distributor(name)
          sns.create_platform_application(
            name:
          )
        end

        def create_channel!(name)
          resp = sns.create_topic(name: name)
          Channel.new(nil, resp.topic_arn)
        end

        def delete_channel!(channel)
          sns.delete_topic(topic_arn: channel.arn)
        end

        def listen_on(channel)
          sns.subscribe(
            topic_arn: channel.arn,
            protocol: 'application'
          )
        end

        def real_channels
          results = []
          next_token = ''
          loop do
            resp = sns.list_topics((next_token.empty? ? {} : { next_token: next_token }))
            results.concat(resp.topics)
            next_token = (resp.next_token.empty? ? '' : resp.next_token)
            break if next_token.empty?
          end
          results
        end

        # Send a message to a Channel using SNS#publish
        # @params: [opts <Hash>]:
        #   this includes all the keys AWS uses but for now it only has defaults
        #   for topic_arn and the message
        # @returns:
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
