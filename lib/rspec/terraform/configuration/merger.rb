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
          left_vars = left[:vars] || {}
          right_vars = right[:vars] || {}
          vars = left_vars.merge(right_vars)

          merged = {}
          unless left_vars == {} && right_vars == {}
            merged = merged.merge(vars: vars)
          end

          merged
        end

        def merge_accumulating_lists(left, right)
          left_var_files = left[:var_files] || []
          right_var_files = right[:var_files] || []
          var_files = left_var_files + right_var_files

          merged = {}
          unless left_var_files == [] && right_var_files == []
            merged = merged.merge(var_files: var_files)
          end

          merged
        end
      end
    end
  end
end
