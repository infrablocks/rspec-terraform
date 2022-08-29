# frozen_string_literal: true

require_relative './helpers/apply'
require_relative './helpers/destroy'
require_relative './helpers/plan'
require_relative './helpers/output'
require_relative './helpers/var'

module RSpec
  module Terraform
    module Helpers
      def apply(overrides = {}, &block)
        RSpec::Terraform::Helpers::Apply
          .new(helper_options)
          .execute(overrides, &block)
      end

      def destroy(overrides = {}, &block)
        RSpec::Terraform::Helpers::Destroy
          .new(helper_options)
          .execute(overrides, &block)
      end

      def output(overrides = {}, &block)
        RSpec::Terraform::Helpers::Output
          .new(helper_options)
          .execute(overrides, &block)
      end

      def plan(overrides = {}, &block)
        RSpec::Terraform::Helpers::Plan
          .new(helper_options)
          .execute(overrides, &block)
      end

      def var(overrides = {}, &block)
        RSpec::Terraform::Helpers::Var
          .new(helper_options)
          .execute(overrides, &block)
      end

      private

      def helper_options
        config = RSpec.configuration

        {
          binary: config.terraform_binary,
          execution_mode: config.terraform_execution_mode,
          configuration_provider: config.terraform_configuration_provider
        }
      end
    end
  end
end
