# frozen_string_literal: true

require 'ruby_terraform'
require 'stringio'

require_relative './command_instantiation'

module RSpec
  module Terraform
    module Helpers
      module Actions
        module Show
          include CommandInstantiation

          def show(parameters, plan_file)
            stdout = StringIO.new
            show_command(stdout: stdout)
              .execute(show_parameters(parameters, plan_file))
            stdout.string
          end

          private

          def show_command(opts = {})
            instantiate_command(RubyTerraform::Commands::Show, opts)
          end

          def show_parameters(parameters, plan_file)
            with_show_plan_file_parameters(
              with_show_standard_parameters(parameters),
              plan_file
            )
          end

          def with_show_standard_parameters(parameters)
            parameters.merge(
              chdir: parameters[:configuration_directory],
              no_color: true,
              json: true
            )
          end

          def with_show_plan_file_parameters(parameters, plan_file)
            parameters.merge(
              path: plan_file
            )
          end
        end
      end
    end
  end
end
