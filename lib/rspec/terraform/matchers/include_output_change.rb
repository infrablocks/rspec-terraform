# frozen_string_literal: true

module RSpec
  module Terraform
    module Matchers
      class IncludeOutputChange
        attr_reader :definition, :value, :plan

        def initialize(definition = {})
          @definition = definition
          @value = nil
        end

        def matches?(plan)
          @plan = plan

          !value_matches(plan).empty?
        end

        def with_value(value)
          @value = maybe_box_value(value)
          self
        end

        def failure_message
          "\nexpected: #{positive_expected_line}" \
            "\n     got: #{positive_got_line}"
        end

        private

        def definition_matches(plan)
          plan.output_changes_matching(definition)
        end

        def value_matches(plan)
          matches = definition_matches(plan)
          return matches unless value

          expected = value_matcher(value)

          matches.filter do |output_change|
            change = output_change.change
            after = change.after_object
            actual = resolved_value(value, after)

            expected&.matches?(actual)
          end
        end

        def maybe_box_value(value)
          if value.respond_to?(:matches?)
            value
          else
            RubyTerraform::Models::Objects.box(value)
          end
        end

        def value_matcher(expected)
          return expected if expected.respond_to?(:matches?)

          RSpec::Matchers::BuiltIn::Eq.new(expected)
        end

        def resolved_value(expected, actual)
          return actual&.unbox if expected.respond_to?(:matches?)

          actual
        end

        def positive_expected_line
          maybe_with_definition(
            positive_plan_line
          )
        end

        def positive_plan_line
          'a plan including at least one output change'
        end

        def maybe_with_definition(expected_line)
          unless @definition.empty?
            expected_line =
              "#{expected_line} matching definition:\n#{definition_lines}"
          end
          expected_line
        end

        def definition_lines
          indent = '            '
          definition
            .collect { |k, v| "#{indent}#{k} = #{v.inspect}" }
            .join("\n")
        end

        def positive_got_line
          if plan.output_changes.empty?
            'a plan including no output changes.'
          else
            with_available_output_changes(
              'a plan including no matching output changes.'
            )
          end
        end

        def with_available_output_changes(got_line)
          "#{got_line}\n          available output changes are:" \
            "\n#{available_output_change_lines}"
        end

        def available_output_change_lines
          available_lines = plan.output_changes.collect do |oc|
            name = oc.name
            actions = oc.change.actions.join(', ')
            "            - #{name} (#{actions})"
          end
          available_lines.join("\n")
        end
      end
    end
  end
end
