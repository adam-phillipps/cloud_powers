module Smash
  module CloudPowers
    class ErrorsWithoutBorders < Exception
      include Singleton
      attr_reader :errors

      def build!(*args)
        ErrCol = Struct.new(:type, :max, :storage) do
          def push!(err_msg)
            storage << err_msg
            throw :die if storage[type].count >= max
          end
        end

        @errors ||= args.inject({}) { |col, t| col.merge(t => ErrCol.new(t, 5, [])) }
      end

      def push!(err_col, message)
        @errors[err_col] << message
      end

      private
      def initialize()
        build!
      end
    end
  end
end
