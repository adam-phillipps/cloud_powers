require 'cloud_powers/aws_resources'
require 'cloud_powers/creatable'
require 'cloud_powers/helpers'
require 'cloud_powers/zenv'

module Smash
  module CloudPowers
    class Resource
      include Smash::CloudPowers::Creatable
      include Smash::CloudPowers::AwsResources
      include Smash::CloudPowers::Helpers
      include Smash::CloudPowers::Zenv

      # client used to make HTTP requests to the cloud
      attr_accessor :client
      # the name this resource can be set and retrieved by
      attr_accessor :call_name
      # the given name for this resource
      attr_accessor :name
      # whether or not a call has been made to the cloud to back this resource
      attr_accessor :linked
      # the ID in the cloud; e.g. ARN for AWS, etc
      attr_accessor :remote_id
      # tracking on the remote resource that maps to this resource
      attr_accessor :tags
      # the type of resource this was instantiated as
      attr_accessor :type

      # Usually this method is called by calling +super+ in another class that
      # inherits from this class.  The initialize method follows the method
      # signature for the active record-like pattern being followed throughout
      # the code
      def initialize(name:, client: nil, **config)
        @linked = false
        @saved = false
        @client = client
        @type = to_snake(self.class.name.split('::').last)
        @call_name = to_snake("#{name}_#{@type}")
        @name = name
        @tags = Array.new
      end
    end
  end
end
