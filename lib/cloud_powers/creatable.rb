require 'cloud_powers/helpers'

module Smash
  module CloudPowers
    # Give an object an
    # Active Record-like interface, with a twist.  Instead of a database, we're
    # using cloud resources. This module includes handy methods that can act
    # like before and after hooks, for object instantiation and cloud-resource
    # creation.  To use the module, you have to participate in the interface,
    # which means you have to follow <i><b>a few rules</b></i>:
    #   1. your +initialize+ method can take a list of keyword arguments or a +Hash+
    #   for configuration
    #   2. your resource class has a <tt>create_resource</tt> method that can
    #   deal with making the http request for creating the resource in the cloud
    #   3. your class extends this module
    module Creatable
      include Smash::CloudPowers::Helpers

      def self.included base
        base.send :include, AfterHooks
        base.extend BeforeHooks
      end

      module BeforeHooks
        # +Boolean+ - tells if this resource is mapped to a resource in the cloud
        attr_accessor :saved

        # A +before_hook+ style method that allows you to do things after you
        # instantiate the resource's object but <b>before</b> you create the
        # resource, in the cloud.  Because we're likely to be in the middle of
        # requesting a resource be requested, in the cloud, this method gives us
        # a means to do some checking, linking and/or setup before we make a request.
        #
        # Parameters
        # * +Hash+ or keyword argument(s) - configuration
        #
        # * +Block+ (optional) - your optional before_hook that runs before you've
        # instantiated your object, yielding the new instance to you, to run in your block.
        #
        # Returns
        # +Object+ - a new instance of the class that extended this module
        def build(name:, **config)
          new_resource = self.new(name: name, **config)
          yield new_resource if block_given?
          new_resource
        end

        # An +after_hook+ style method that allows you to do things after you
        # instantiate the resource's object, but before you create the resource,
        # in the cloud.  Because we're likely to be in the middle of requesting to
        # create a resource, in the cloud, this method
        # gives us a means to do some checking or setup after we make a request.
        #
        # Parameters
        # * +Hash+ or keyword argument(s) - configuration
        #
        # * +Block+ (optional) - your optional after_hook that runs after you've
        # created your resource(s) in the cloud, yielding the new instance to you,
        # to run in your block.
        #
        # Returns
        # +Object+ - a new instance of the class that extended this module
        #
        # Notes
        # * See <tt>#build</tt>
        # * See <tt>#save!</tt>
        # * See <tt>CloudPowers::Helpers::LogicHelp#instance_attr_accessor</tt>
        # * See <tt>CloudPowers::Helpers::LogicHelp#attr_map</tt>
        def create!(name:, **config)
          new_resource = self.build(name: name, **config)

          new_resource.attr_map(config) do |config_key, config_value|
            new_resource.instance_attr_accessor new_resource.to_snake(config_key)
            config_value
          end

          new_resource.save!

          yield new_resource if block_given?
          new_resource
        end
      end

      module AfterHooks
        # Alternative to <tt>save!()</tt>.  This predicate method is based off
        # the <tt>@linked</tt> i-var and is set to true after it has been confirmed
        # that this resource is a good map to the resource in the cloud.
        #
        # Returns
        # * +Boolean+
        def linked?
          !!@linked
        end

        # An +after_hook+ style method that sends a reqeust to your custom implementation
        # of the <tt>create_resource</tt> methodallows you to do things after you
        # create the resource, in the cloud.  This method relies on you having
        # a <tt>create_resource</tt> method that can handle every aspect of creating
        # your resource.  If this piece of the contract isn't obeyed, you will
        # receive a <tt>NoMethodError</tt>.
        #
        # Returns
        # +Boolean+ - +true+ if the resource
        def save!
          resp = create_resource if self.respond_to? :create_resource
          @saved = !resp.nil?
        end

        # Find out if the resource was created
        #
        # Returns
        # +Boolean+
        def saved?
          !!@saved
        end
      end
    end
  end
end



