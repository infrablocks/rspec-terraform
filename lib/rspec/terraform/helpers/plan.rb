# frozen_string_literal: true

require 'ruby_terraform'
require 'securerandom'
require 'stringio'

require_relative './base'

module RSpec
  module Terraform
    module Helpers
      class Plan < Base
        def execute(overrides = {}, &block)
          parameters = with_configuration_provider_parameters(overrides)
          parameters = with_resolved_vars(parameters, &block)

          validate(parameters)
          clean(parameters)
          init(parameters)
          plan_file = plan(parameters)
          plan_contents = show(parameters, plan_file)
          remove(parameters, plan_file)
          parse(plan_contents)
        end

        private

        def required_parameters(execution_mode)
          {
            in_place: [:configuration_directory],
            isolated: %i[source_directory configuration_directory]
          }[execution_mode] || []
        end

        def clean(parameters)
          return unless execution_mode == :isolated

          FileUtils.rm_rf(parameters[:configuration_directory])
          FileUtils.mkdir_p(parameters[:configuration_directory])
        end

        def init(parameters)
          init_command.execute(init_parameters(parameters))
        end

        def plan(parameters)
          plan_parameters = plan_parameters(parameters)
          plan_command.execute(plan_parameters)
          plan_parameters[:out]
        end

        def show(parameters, plan_file)
          stdout = StringIO.new
          show_command(stdout: stdout)
            .execute(show_parameters(parameters, plan_file))
          stdout.string
        end

        def parse(plan_contents)
          RubyTerraform::Models::Plan.new(
            JSON.parse(plan_contents, symbolize_names: true)
          )
        end

        def remove(parameters, plan_file)
          FileUtils.rm_f(
            File.join(parameters[:configuration_directory], plan_file)
          )
        end

        def init_command
          RubyTerraform::Commands::Init.new(command_options)
        end

        def plan_command
          RubyTerraform::Commands::Plan.new(command_options)
        end

        def show_command(opts = {})
          RubyTerraform::Commands::Show.new(command_options.merge(opts))
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

        # rubocop:disable Metrics/MethodLength
        def plan_parameters(parameters)
          plan_parameters =
            parameters.merge(
              chdir: parameters[:configuration_directory],
              out: parameters[:plan_file_name] ||
                "#{SecureRandom.hex[0, 10]}.tfplan",
              input: false
            )

          if parameters[:state_file]
            plan_parameters =
              plan_parameters.merge(state: parameters[:state_file])
          end

          plan_parameters
        end
        # rubocop:enable Metrics/MethodLength

        def show_parameters(parameters, plan_file)
          parameters.merge(
            chdir: parameters[:configuration_directory],
            path: plan_file,
            no_color: true,
            json: true
          )
        end
      end
    end
  end
end
