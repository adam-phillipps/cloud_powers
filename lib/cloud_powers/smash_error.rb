require 'singleton'

module Smash
  module CloudPowers
    class SmashError < Exception
      include Singleton

      attr_reader :errors, :error_collections

      ErrorCollection = Struct.new(:type, :max, :storage) do
        def push!(err_msg)
          storage << err_msg
          throw :die if storage[type].count >= max
        end
      end

      def build!(*args)

        @errors ||= args.inject({}) do |col, t|
          col.merge(t => ErrCol.new(t, 5, []))
        end
      end

      def push_error!(type, message)
        @errors[type].push!(message)
      end

      private
      def initialize
      end
    end
  end
end
