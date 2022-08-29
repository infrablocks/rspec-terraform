# frozen_string_literal: true

require 'ruby_terraform'

module RSpec
  module Terraform
    module Helpers
      class Output
        attr_reader(
          :configuration_provider, :binary, :execution_mode
        )

        def initialize(opts = {})
          @configuration_provider =
            opts[:configuration_provider] || Configuration.identity_provider
          @binary = opts[:binary] || 'terraform'
          @execution_mode = opts[:execution_mode] || :in_place
        end

        def execute(overrides = {})
          parameters = with_configuration_provider_parameters(overrides)
          parameters = with_mandatory_parameters(parameters)

          ensure_required_parameters(parameters)

          clean(parameters)
          init(parameters)
          output_value = output(parameters)

          JSON.parse(output_value, symbolize_names: true)
        end

        private

        def with_configuration_provider_parameters(parameters)
          configuration_provider.resolve(parameters)
        end

        def with_mandatory_parameters(parameters)
          parameters.merge(
            json: true
          )
        end

        def required_parameters(execution_mode)
          {
            in_place: %i[name configuration_directory],
            isolated: %i[name source_directory configuration_directory]
          }[execution_mode] || []
        end

        def ensure_required_parameters(parameters)
          missing_parameters =
            required_parameters(execution_mode)
              .filter { |parameter| parameters[parameter].nil? }

          return if missing_parameters.empty?

          raise_missing_parameters(missing_parameters)
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

        def clean(parameters)
          return unless execution_mode == :isolated

          FileUtils.rm_rf(parameters[:configuration_directory])
          FileUtils.mkdir_p(parameters[:configuration_directory])
        end

        def init(parameters)
          init_command.execute(init_parameters(parameters))
        end

        def output(parameters)
          stdout = StringIO.new
          output_command(stdout: stdout)
            .execute(output_parameters(parameters))
          stdout.string
        end

        def init_command
          RubyTerraform::Commands::Init.new(binary: binary)
        end

        def output_command(opts = {})
          RubyTerraform::Commands::Output.new(opts.merge(binary: binary))
        end

        def init_parameters(parameters)
          init_parameters = parameters.merge(
            chdir: parameters[:configuration_directory],
            input: false
          )
          if execution_mode == :isolated
            init_parameters =
              init_parameters.merge(from_module: parameters[:source_directory])
          end

          init_parameters
        end

        def output_parameters(parameters)
          output_parameters =
            parameters.merge(
              chdir: parameters[:configuration_directory]
            )

          if parameters[:state_file]
            output_parameters =
              output_parameters.merge(state: parameters[:state_file])
          end

          output_parameters
        end
      end
    end
  end
end
