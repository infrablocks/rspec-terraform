# frozen_string_literal: true

require 'ruby_terraform'

require_relative '../configuration/var_captor'

module RSpec
  module Terraform
    module Helpers
      class Apply
        attr_reader(:overrides, :configuration_provider)

        def initialize(overrides = {}, configuration_provider = nil)
          @overrides = overrides
          @configuration_provider =
            configuration_provider || Configuration.identity_provider
        end

        def execute(&block)
          parameters = with_configuration_provider_parameters(overrides)
          parameters = with_resolved_vars(parameters, &block)
          parameters = with_mandatory_parameters(parameters)

          ensure_required_parameters(parameters)

          init(parameters)
          apply(parameters)
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
          parameters.merge(
            input: false,
            auto_approve: true
          )
        end

        def ensure_required_parameters(parameters)
          return if parameters[:configuration_directory]

          throw StandardError.new(
            'No Terraform configuration directory specified.'
          )
        end

        def init(parameters)
          init_command.execute(
            chdir: parameters[:configuration_directory],
            input: parameters[:input]
          )
        end

        def apply(parameters)
          apply_command.execute(
            chdir: parameters[:configuration_directory],
            state: parameters[:state_file],
            vars: parameters[:vars],
            input: parameters[:input],
            auto_approve: parameters[:auto_approve]
          )
        end

        def init_command
          RubyTerraform::Commands::Init.new(
            binary: RSpec.configuration.terraform_binary
          )
        end

        def apply_command
          RubyTerraform::Commands::Apply.new(
            binary: RSpec.configuration.terraform_binary
          )
        end
      end
    end
  end
end
