module Smash
  module CloudPowers
    module Synapse
      module Broadcast
        include Smash::CloudPowers::AwsResources
        include Smash::CloudPowers::Helper
        include Smash::CloudPowers::Zenv

        Channel = Struct.new(:set_name, :set_arn) do
          def arn
            "arn:aws:sns:#{zfind(:region)}:#{zfind(:accound_number)}:bla"
          end

          def name
          end
        end # end Channel
        #################

        def listen_to(channel)
          sns.subscribe(
            topic_arn: channel.arn,
            protocol: 'https'
          )
        end

        def real_channels
          results = []
          next_token = ''
          loop do
            resp = sns.list_topics((next_token.empty? ? {} : { next_token: next_token }))
            results.concat(resp.topics)
            next_token = resp.next_token.empty? ? break : resp.next_token
          end
          results
        end

        def send(opts = {})
          msg_attrs = {
            "String" => {
              data_type:          "String", # required
              string_value:       "String",
              binary_value:       "data"
            }.merge(opts.delete(:message_attributes))

          package = {
            topic_arn:            "topicARN",
            target_arn:           "String",
            phone_number:         "String",
            message:              "message", # required
            subject:              "subject",
            message_structure:    "messageStructure",
            message_attributes:   msg_attrs
          }.merge(opts)

          sns.publish(package)
        end

        def create_channel(name)
          sns.create_topic(name: name)
        end

        def delete_channel(channel)
          sns.delete_topic(topic_arn: channel.arn)
        end

        def listen_on(channel)
          sns.subscribe(
            topic_arn: channel.arn,
            protocol: 'https'
          )
        end
      end
    end
  end
end
