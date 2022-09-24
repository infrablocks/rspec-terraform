# frozen_string_literal: true

require_relative '../configuration/var_captor'

module RSpec
  module Terraform
    module Helpers
      # rubocop:disable Metrics/ModuleLength
      module Actions
        def execute_if_required(parameters, &block)
          only_if = parameters[:only_if]
          only_if_args = only_if ? [parameters].slice(0, only_if.arity) : []
          should_execute = only_if ? only_if.call(*only_if_args) : true

          block.call if should_execute
        end

        def clean(parameters)
          return unless execution_mode == :isolated

          FileUtils.rm_rf(parameters[:configuration_directory])
          FileUtils.mkdir_p(parameters[:configuration_directory])
        end

        def remove(parameters, file)
          FileUtils.rm_f(
            File.join(parameters[:configuration_directory], file)
          )
        end

        def validate(parameters)
          missing_parameters =
            required_parameters(execution_mode)
              .filter { |parameter| parameters[parameter].nil? }

          return if missing_parameters.empty?

          raise_missing_parameters(missing_parameters)
        end

        def init(parameters)
          init_command.execute(init_parameters(parameters))
        end

        def apply(parameters)
          apply_command.execute(apply_parameters(parameters))
        end

        def destroy(parameters)
          destroy_command.execute(destroy_parameters(parameters))
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

        def output(parameters)
          stdout = StringIO.new
          output_command(stdout: stdout)
            .execute(output_parameters(parameters))
          stdout.string
        end

        private

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

        def instantiate_command(klass, opts = {})
          klass.new(command_options.merge(opts))
        end

        def init_command
          instantiate_command(RubyTerraform::Commands::Init)
        end

        def apply_command
          instantiate_command(RubyTerraform::Commands::Apply)
        end

        def destroy_command
          instantiate_command(RubyTerraform::Commands::Destroy)
        end

        def plan_command
          instantiate_command(RubyTerraform::Commands::Plan)
        end

        def show_command(opts = {})
          instantiate_command(RubyTerraform::Commands::Show, opts)
        end

        def output_command(opts = {})
          instantiate_command(RubyTerraform::Commands::Output, opts)
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
        def apply_parameters(parameters)
          apply_parameters =
            parameters.merge(
              chdir: parameters[:configuration_directory],
              input: false,
              auto_approve: true
            )

          if parameters[:state_file]
            apply_parameters =
              apply_parameters.merge(state: parameters[:state_file])
          end

          apply_parameters
        end
        # rubocop:enable Metrics/MethodLength

        # rubocop:disable Metrics/MethodLength
        def destroy_parameters(parameters)
          destroy_parameters =
            parameters.merge(
              chdir: parameters[:configuration_directory],
              input: false,
              auto_approve: true
            )

          if parameters[:state_file]
            destroy_parameters =
              destroy_parameters.merge(state: parameters[:state_file])
          end

          destroy_parameters
        end
        # rubocop:enable Metrics/MethodLength

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
      # rubocop:enable Metrics/ModuleLength
    end
  end
end
