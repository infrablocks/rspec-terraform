# frozen_string_literal: true

module RSpec
  module Terraform
    module Helpers
      module Actions
        module Clean
          def clean(parameters)
            return unless execution_mode == :isolated

            configuration_directory = parameters[:configuration_directory]

            log_clean_starting(configuration_directory)

            FileUtils.rm_rf(configuration_directory)
            FileUtils.mkdir_p(configuration_directory)

            log_clean_complete
          end

          private

          def log_clean_starting(configuration_directory)
            logger&.info(
              'Cleaning configuration directory: ' \
              "'#{configuration_directory}'..."
            )
          end

          def log_clean_complete
            logger&.info('Clean complete.')
          end
        end
      end
    end
  end
end
