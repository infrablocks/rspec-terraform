# frozen_string_literal: true

require_relative 'parameters'

module RSpec
  module Terraform
    module Helpers
      class Base
        include Parameters

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
