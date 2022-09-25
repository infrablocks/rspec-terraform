# frozen_string_literal: true

module RSpec
  module Terraform
    module Helpers
      module Actions
        module Clean
          def clean(parameters)
            return unless execution_mode == :isolated

            FileUtils.rm_rf(parameters[:configuration_directory])
            FileUtils.mkdir_p(parameters[:configuration_directory])
          end
        end
      end
    end
  end
end
