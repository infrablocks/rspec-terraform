# frozen_string_literal: true

require_relative '../configuration/var_captor'

module RSpec
  module Terraform
    module Helpers
      class Base
        attr_reader(
          :configuration_provider,
          :binary,
          :logger,
          :stdin,
          :stdout,
          :stderr,
          :execution_mode
        )

        def initialize(opts = {})
          @configuration_provider =
            opts[:configuration_provider] || Configuration.identity_provider
          @binary = opts[:binary] || 'terraform'
          @logger = opts[:logger]
          @stdin = opts[:stdin]
          @stdout = opts[:stdout]
          @stderr = opts[:stderr]
          @execution_mode = opts[:execution_mode] || :in_place
        end

        private

        def with_configuration_provider_parameters(parameters)
          configuration_provider.resolve(parameters)
        end

        def with_resolved_vars(parameters, &block)
          return parameters unless block_given?

          var_captor = Configuration::VarCaptor.new(parameters[:vars] || {})
          block.call(var_captor)
          parameters.merge(vars: var_captor.to_h)
        end

        def with_mandatory_parameters(parameters)
          parameters.merge(mandatory_parameters)
        end

        def raise_missing_parameters(parameters)
          parameters = parameters.collect { |parameter| "`:#{parameter}`" }
          if parameters.count == 1
            raise StandardError,
                  "Required parameter: #{parameters[0]} missing."
          else
            parameters = "#{parameters[..-2].join(', ')} and #{parameters[-1]}"
            raise StandardError,
                  "Required parameters: #{parameters} missing."
          end
        end

        def validate(parameters)
          missing_parameters =
            required_parameters(execution_mode)
              .filter { |parameter| parameters[parameter].nil? }

          return if missing_parameters.empty?

          raise_missing_parameters(missing_parameters)
        end

        def mandatory_parameters
          {}
        end

        def required_parameters(_)
          []
        end

        def command_options
          {
            binary: binary,
            logger: logger,
            stdin: stdin,
            stdout: stdout,
            stderr: stderr
          }
        end
      end
    end
  end
end
