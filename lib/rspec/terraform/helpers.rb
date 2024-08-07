# frozen_string_literal: true

require_relative 'helpers/apply'
require_relative 'helpers/destroy'
require_relative 'helpers/plan'
require_relative 'helpers/output'
require_relative 'helpers/var'

module RSpec
  module Terraform
    module Helpers
      def apply(overrides = {}, &)
        RSpec::Terraform::Helpers::Apply
          .new(helper_options)
          .execute(overrides, &)
      end

      def destroy(overrides = {}, &)
        RSpec::Terraform::Helpers::Destroy
          .new(helper_options)
          .execute(overrides, &)
      end

      def output(overrides = {}, &)
        RSpec::Terraform::Helpers::Output
          .new(helper_options)
          .execute(overrides, &)
      end

      def plan(overrides = {}, &)
        RSpec::Terraform::Helpers::Plan
          .new(helper_options)
          .execute(overrides, &)
      end

      def var(overrides = {}, &)
        RSpec::Terraform::Helpers::Var
          .new(helper_options)
          .execute(overrides, &)
      end

      private

      def helper_options
        config = RSpec.configuration

        {
          binary: config.terraform_binary,
          logger: config.terraform_logger,
          stdin: config.terraform_stdin,
          stdout: config.terraform_stdout,
          stderr: config.terraform_stderr,
          execution_mode: config.terraform_execution_mode,
          configuration_provider: config.terraform_configuration_provider
        }
      end
    end
  end
end
