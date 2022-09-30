# frozen_string_literal: true

require 'fileutils'

module RSpec
  module Terraform
    module Helpers
      module Actions
        module Remove
          def remove(parameters, file)
            configuration_directory = parameters[:configuration_directory]

            log_remove_starting(configuration_directory, file)

            FileUtils.rm_f(
              File.join(configuration_directory, file)
            )

            log_remove_complete
          end

          private

          def log_remove_starting(configuration_directory, file)
            logger&.info(
              "Removing file: '#{file}' in configuration directory: " \
              "'#{configuration_directory}'..."
            )
          end

          def log_remove_complete
            logger&.info('Remove complete.')
          end
        end
      end
    end
  end
end
