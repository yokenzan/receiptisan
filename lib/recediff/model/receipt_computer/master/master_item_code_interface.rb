# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class Master
        # 検索用のコード
        module MasterItemCodeInterface
          include Comparable

          module ExtendedClassMethod
            # @return [MasterItemCodeInterface]
            def of(code)
              raise StandardError, 'invalid code of %s : %s' % [__name, code] unless code.to_s =~ /\A[0-9]+\z/

              new(code)
            end

            def __name
              raise NotImplementedError
            end

            def __digit_length
              9
            end
          end

          def self.included(klass)
            klass.extend ExtendedClassMethod
          end

          def initialize(code)
            @code = code

            unless __to_code.length == self.class.__digit_length
              raise StandardError, 'invalid code of %s : %s' % [self.class.__name, code]
            end
          end

          # @return [String]
          def name
            self.class.__name
          end

          # @return [Symbol]
          def value
            __to_code.intern
          end

          def <=>(other)
            other_value =
              case other
              when self.class
                other.value
              else
                self.class.of(other).value
              end

            value <=> other_value
          end

          # @return [String]
          def __to_code
            "%0#{self.class.__digit_length}d" % @code.to_s.to_i
          end
        end
      end
    end
  end
end
