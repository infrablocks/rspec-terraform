# frozen_string_literal: true

require 'fileutils'

module RSpec
  module Terraform
    module Helpers
      module Actions
        module Remove
          def remove(parameters, file)
            FileUtils.rm_f(
              File.join(parameters[:configuration_directory], file)
            )
          end
        end
      end
    end
  end
end
