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

        attr_map(context: context_resource) do |c_name, context|
          instance_attr_accessor c_name
          [c_name, context]
        end

        context_resource.description.each do |type, descriptions|
          next unless descriptions.respond_to? :each
          resource = create_resource(type) if descriptions.empty?
          descriptions.each { |config| create_resource(type, config) }
        end

        # create_resources(context_resource.description)
        context
      end

      # Create a resource of the given type and description
      #
      # Parameters
      # * type +String+|+Symbol+
      # * description +Hash+
      #
      # Returns
      # description
      def create_resource(type, description = {})
        resource = try_to_instantiate_or_not(type, description)
        r_name = resource.name || type rescue type
        attr_map(r_name => resource) do |r_name, r|
          instance_attr_accessor r_name
          [r_name, r]
        end
      end

      private
      # Attempt to create a resource with supported interfaces and finally
      # try with a .new() method call.  If all else fails, return +nil+
      def try_to_instantiate_or_not(type, config)
        send_interface_create(type, config)   ||
          send_resource_create(type, config)  ||
          send_new(type, config)              ||
          config
      end

      # Attempt to make a resource using the interface or return +nil+
      def send_interface_create(type, config)
        method_name = "create_#{type}"
        resource = nil # hoisting for scope

        if self.respond_to? method_name
          self.public_send(method_name, **config)
        end
      end

      # Attempt to make a resource using the Resource module or return +nil+
      def send_resource_create(type, config)
        begin
          resource = Smash.const_get(to_pascal(type))
          if resource.respond_to? :create!
            resource.create!(name: config.delete(:name), **config)
          end
        rescue NameError => e
          logger.info format_error_message e
        end
      end

      # Attempt to find the appropriate class and instantiate like normal
      def send_new(type, config)
        begin
          Smash.const_get(to_pascal(type)).new(config)
        rescue NameError => e
          logger.info format_error_message e
        end
      end
    end
  end
end
