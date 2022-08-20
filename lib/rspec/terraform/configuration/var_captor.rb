# frozen_string_literal: true

module RSpec
  module Terraform
    module Configuration
      class VarCaptor
        def initialize(vars)
          @vars = vars
        end

        def method_missing(method, *args, &_)
          if method.to_s =~ /.*=$/
            set_var(method.to_s.chop.to_sym, args[0])
          else
            read_var(method)
          end
        end

        def respond_to_missing?
          true
        end

        def to_h
          @vars
        end

        private

        def set_var(var, value)
          @vars[var] = value
        end

        def read_var(var)
          @vars[var]
        end
      end
    end
  end
end
