require 'uri'
require 'cloud_powers/synapse/queue/resource'

module Smash
  module CloudPowers
    module Synapse
      module Queue
        include Smash::CloudPowers::AwsResources
        include Smash::CloudPowers::Helpers

        # A simple Struct that acts as a Name to URL map
        #
        # Parameters
        # * :set_name +String+ (optional) - An optional name.  It should be the same name as the
        #   the QueueResource and/or Queue you're working with, or else this Struct isn't that useful
        # * :set_url +String+ (optional) - An optional URL.  It should be the same URL as the
        #   the QueueResource and/or Queue you're working with, or else this Struct isn't that useful
        #
        # Attributes
        # * name +String+ - the +:set_name+ or parse the +#address()+ for the name
        # * url +String+ - the +:set_url+ or add the name to the end of a best guess at the URL
        #
        # Example
        #   name_url_map = NUMap.new(nil, 'https://sqs.us-west-53.amazonaws.com/001101010010/fooBar')
        #   name_url_map.name
        #   # => 'fooBar'
        #
        #   # and now in reverse
        #   url_name_map = NUMap.new('snargleBargle')
        #   url_name_map.address
        #   # => 'https://sqs.us-west-53.amazonaws.com/001101010010/snargleBargle'
        NUMap = Struct.new(:set_name, :set_url) do
          # Gives you back the name, even if it hasn't been set
          #
          # Returns
          # +String+
          def name
            set_name || url.split('/').last # Queue names are last in the URL path
          end

          # Gives you back the URL, even if it hasn't been set
          #
          # Returns
          # +String+
          def url
            set_url || Smash::CloudPowers::Synapse::Queue::Resource.new(name: name).best_guess_address
          end
        end

        # This method can be used to parse a queue name from its address.  It can be handy if you need the name
        # of a queue but you don't want the overhead of creating a QueueResource object.
        #
        # Parameters
        # * url +String+
        #
        # Returns
        # +String+
        #
        # Example
        #   resource_name('https://sqs.us-west-53.amazonaws.com/001101010010/fooBar')
        #   => fooBar
        def queue_name(url)
          url.to_s.split('/').last
        end

        # This method builds a Queue::QueueResource object for you to use but doesn't
        # invoke the <tt>#create!()</tt> method, so no API call is made to create the Queue
        # on SQS.  This can be used if the QueueResource and/or Queue already exists.
        #
        # Parameters
        # * name +String+ - name of the Queue you want to interact with
        #
        # Returns
        # Queue::QueueResource
        #
        # Example
        #   queue_object = build_queue('exampleQueue')
        #   queue_object.address
        #   => https://sqs.us-west-2.amazonaws.com/81234567/exampleQueue
        def build_queue(name)
          Smash::CloudPowers::Synapse::Queue::Resource.build(name: to_camel(name), sqs)
        end

        # This method allows you to create a queue on SQS without explicitly creating a QueueResource object
        #
        # Parameters
        # * name +String+ - The name of the Queue to be created
        #
        # Returns
        # Queue::QueueResource
        #
        # Example
        #   create_queue('exampleQueue')
        #   get_queue_message_count
        def create_queue(name)
          queue = Smash::CloudPowers::Synapse::Queue::Resource.create!(name: to_camal(name), client: sqs)
          instance_attr_accessor name: queue.full_name
        end

        # Deletes a queue message without caring about reading/interacting with the message.
        # This is usually used for progress tracking, ie; a Neuron takes a message from the Backlog, moves it to
        # WIP and deletes it from Backlog.  Then repeats these steps for the remaining States in the Workflow
        #
        # Parameters
        # * queue +String+ - queue is the name of the +Queue+ to interact with
        # * opts +Hash+ (optional) - a configuration +Hash+ for the +SQS::QueuePoller+
        #
        # Notes
        # * throws :stop_polling after the message is deleted
        #
        # Example
        #   get_queue_message_count('exampleQueue')
        #   # => n
        #   delete_queue_message('exampleQueue')
        #   get_queue_message_count('exampleQueue')
        #   # => n-1
        def delete_queue_message(queue, opts = {})
          poll(queue, opts) do |msg, stats|
            poller(queue).delete_message(msg)
            throw :stop_polling
          end
        end

        # This method is used to get the approximate count of messages in a given queue
        #
        # Parameters
        # * resource_url +String+ - the URL for the resource you need to get a count from
        #
        # Returns
        # +Float+
        #
        # Example
        #   get_queue_message_count('exampleQueue')
        #   # => n
        #   delete_queue_message('exampleQueue')
        #   get_queue_message_count('exampleQueue')
        #   # => n-1
        def get_queue_message_count(resource_url)
          sqs.get_queue_attributes(
            queue_url: resource_url,
            attribute_names: ['ApproximateNumberOfMessages']
          ).attributes['ApproximateNumberOfMessages'].to_f
        end

        # Get a message from a Queue
        #
        # Parameters
        # * resource<String|symbol>: The name of the resource
        #
        # Returns
        # * +String+ if +msg.body+ is not valid JSON
        # * +Hash+ if +msg.body+ is valid JSON
        #
        # Example
        #   # msg.body == 'Hey' # +String+
        #   pluck_queue_message('exampleQueue')
        #   # => 'Hey' # +String+
        #
        #   # msg.body == "\{"tally":"ho"\}" # +JSON+
        #   pluck_queue_message('exampleQueue')
        #   # => { 'tally' => 'ho' } # +Hash+
        def pluck_queue_message(resource)
          poll(resource) do |msg, poller|
            poller.delete_message(msg)
            return valid_json?(msg.body) ? JSON.parse(msg.body) : msg.body
          end
        end

        # Polls the given resource with the given options hash and a block that interacts with
        # the message that is retrieved from the queue
        #
        # Parameters
        # * +resource+ +String+ - the name of the queue you want to poll
        # * +opts+ +Hash+ - costomizes the Aws::SQS::QueuePoller's <tt>#poll(<b>opts</b>)</tt> method
        # and can have any +AWS::SQS:QueuePoller+ polling configuration option(s)
        # * +block+ is the block that is used to interact with the message that was retrieved
        #
        # Returns
        # the results from the +message+ and the +block+ that interacts with the +message(s)+
        #
        # Example
        #   # continuously run jobs from messages in the Queue and leaves the message in the queue
        #   # using the +:skip_delete+ parameter
        #   poll(:backlog, :skip_delete) do |msg|
        #     demo_job = Job.new(msg.body)
        #     demo_job.run
        #   end
        def poll(queue_name, opts = {})
          this_poller = queue_poller(queue_name)
          results = nil
          this_poller.poll(opts) do |msg|
            results = yield msg, this_poller if block_given?
            this_poller.delete_message(msg)
            throw :stop_polling
          end
          results
        end

        def queue_name(base_name)
          %r{_queue$} =~ base_name ? base_name : "#{base_name}_queue"
        end

        # This method can be used to gain a SQS::QueuePoller.  It creates a
        # QueueResource object, the QueueResource then sends the API call to
        # SQS to create the queue and sets an instance variable, using the
        # resource's name, to the QueueResource object itself
        #
        # Parameters
        # * resource_name +String+ - name of the Queue you want to gain a QueuePoller for
        #
        # Returns
        # <tt>resource_name:Queue::QueueResource</tt>
        #
        # Notes
        # * An instance variable is set with this method, if one doesn't exist
        # for the resource. The instance variable that is created/used is named
        # the same name that was given as
        # a parameter.
        #
        # Example
        #   # these are equivalent after @exp_queue_poller is set but before it is set,
        #   # exp_queue_poller
        #   queue_poller('exampleQueue').poll { |msg| Job.new(msg.body).run }
        #   @example_queue.poll { |msg| Job.new(msg.body).run }
        def queue_poller(queue_name)
          i_var_name = to_i_var("#{queue_name}_poller")
          unless instance_variable_defined?(i_var_name)
            resource = Smash::CloudPowers::Queue::Resource.create!(
              name: queue_name,
              client: sqs
            )
            instance_variable_set(i_var_name, resource.poller)
          end

          instance_variable_get(i_var_name)
        end

        # Checks SQS for the existence of this queue using the <tt>#queue_search()</tt> method
        #
        # Parameters
        # * name +String+
        #
        # Returns
        # Boolean
        #
        # Notes
        #   * see <tt>#queue_search()</tt>
        def queue_exists?(name)
          !queue_search(name).empty?
        end

        # Searches for a queue based on the name
        #
        # Parameters
        # name +String+
        #
        # Returns
        # queue_urls +String+
        #
        # Example
        #   results = queue_search('exampleQueue') # returns related URLs
        #   results.first =~ /exampleQueue/ # regex match against the URL
        def queue_search(name)
          sqs.list_queues(queue_name_prefix: name).queue_urls
        end

        # Sends a given message to a given queue
        #
        # Parameters
        # * address +String+ - address of the Queue you want to interact with
        # * message +String+ - message to be sent
        #
        # Returns
        # <tt>Array<String></tt> - Array of URLs
        #
        # Example
        #   legit_address = 'https://sqs.us-west-2.amazonaws.com/12345678/exampleQueue'
        #   random_message = 'Wowza, this is pretty easy.'
        #   resp = send_queue_message(legit_address, random_message))
        #   resp.message_id
        #   => 'some message id'
        def send_queue_message(address, message, this_sqs = sqs)
          this_sqs.send_message(queue_url: address, message_body: message)
        end
      end
    end
  end
end
