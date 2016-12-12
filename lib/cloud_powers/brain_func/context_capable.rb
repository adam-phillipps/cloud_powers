require 'cloud_powers/brain_func/context'
require 'cloud_powers/helpers'

module Smash
  module BrainFunc
    module ContextCapable
      include Smash::CloudPowers::Helpers

      # Build a new +Context+ object to work with.  This method allows for an
      # after instantiation hook and basically follows the same interface as
      # all the other resources.  The only difference is that the +Context+ is
      # better suited to deal with JSON.
      #
      # Parameters
      # * args (optional) - Should be a valid description of arguments for a
      # <tt>Smash::BrainFunc::Context</tt>
      #
      # Returns
      # * <tt>Smash::BrainFunc::Context</tt>
      #
      # Notes
      # * See <tt>Smash::BrainFunc::Context#new</tt> for valid arguments
      def build_context(*args)
        new_context = Smash::BrainFunc::Context.new(*args)
        yield new_context if block_given?
        new_context
      end

      # Create a new +Context+ object to work with and set an instance variable
      # with attr_accessor abilities along with all the resources in the
      # description.  The resources are created using a call to the proper module
      # that contains the resource class, using the <tt>create_<resource></tt>
      # method, provided by the module.
      #
      # Parameters
      # * args (optional) - Should be a valid description of arguments for a
      # <tt>Smash::BrainFunc::Context</tt>
      #
      # Returns
      # * <tt>Smash::BrainFunc::Context</tt>
      #
      # Notes
      # * See <tt>Smash::BrainFunc::Context#new</tt> for valid arguments
      # * See <tt>#create_resources()</tt> - responsible for building all the
      #   resources in the description
      def create_context(*args)
        context_resource = build_context(*args)

        attr_map(context: context_resource) do |attr_name, context_resource|
          instance_attr_accessor attr_name
          [attr_name, context_resource]
        end

        create_resources(context_resource.description)
        context
      end

      # Create all the resources in a description.  This method relies heavily
      # on an active record-like pattern.  Each resource is contained in a module
      # with similar resources.  The module has the ability to _create_ resources
      # of a certain type with the same method signature.  As long as your
      # resource can adhere to one or more of the following rules, you should be
      # able to create all the resources in the description with this one method
      # call
      #
      # Parameters
      # * description +Hash+ - see <tt>Smash::BrainFunc::Context</tt> ->
      #   +new+ and <tt>@description</tt>
      #
      # Returns
      # * description
      #
      # Notes
      # * See <tt>Smash::CloudPowers::Resource</tt> for <tt>create!</tt> usage
      # * See <tt>Smash::CloudPowers::Context</tt> for valid description
      # * See documentation for a full description of the interface and how it
      #   is used here.
      def create_resources(description)
        description.each do |type, configs|
          method_name = "create_#{type}"

          configs.each do |config|
            if self.respond_to? method_name
              self.public_send method_name, config
            else
              resource = self.class.const_get(to_pascal(type))
              if resource.respond_to? :create!
                resource.create!(name: config.delete(:name), **config)
              end
            end
          end
        end
      end
    end
  end
end
