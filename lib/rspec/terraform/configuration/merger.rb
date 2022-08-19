# frozen_string_literal: true

module RSpec
  module Terraform
    module Configuration
      class Merger
        def merge(left, right)
          merge_top_level(left, right)
            .merge(merge_accumulating_maps(left, right))
            .merge(merge_accumulating_lists(left, right))
        end

        private

        def merge_top_level(left, right)
          left.merge(right)
        end

        def merge_accumulating_maps(left, right)
          %i[vars backend_config].inject({}) do |merged, parameter|
            merge_accumulating_map(parameter, merged, left, right)
          end
        end

        def merge_accumulating_map(parameter, accumulator, left, right)
          left_value = left[parameter] || {}
          right_value = right[parameter] || {}
          merged_value = left_value.merge(right_value)

          return accumulator if merged_value == {}

          accumulator.merge(parameter => merged_value)
        end

        def merge_accumulating_lists(left, right)
          %i[var_files targets replaces plugin_dirs platforms]
            .inject({}) do |merged, parameter|
            merge_accumulating_list(parameter, merged, left, right)
          end
        end

        def merge_accumulating_list(parameter, accumulator, left, right)
          left_value = left[parameter] || []
          right_value = right[parameter] || []
          merged_value = left_value + right_value

          return accumulator if merged_value == []

          accumulator.merge(parameter => merged_value)
        end
      end
    end
  end
end
