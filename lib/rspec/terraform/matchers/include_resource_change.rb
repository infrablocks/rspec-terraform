# frozen_string_literal: true

require 'rspec/core'
require 'rspec/matchers'
require 'rspec/matchers/built_in/eq'
require 'rspec/matchers/built_in/count_expectation'

module RSpec
  module Terraform
    module Matchers
      class IncludeResourceChange
        include RSpec::Matchers::BuiltIn::CountExpectation

        attr_reader :definition

        def initialize(definition = {})
          @definition = definition
          @attributes = []
        end

        def matches?(plan)
          matches = attribute_matches(plan)

          match_count = matches.count
          if has_expected_count?
            expected_count_matches?(match_count)
          else
            match_count.positive?
          end
        end

        def with_attribute_value(*args)
          stage, path, value = args.count == 3 ? args : [:after, *args]
          path = [path] if path.is_a?(Symbol)
          @attributes << { stage: stage, path: path, value: value }
          self
        end

        private

        def definition_matches(plan)
          plan.resource_changes_matching(definition)
        end

        def attribute_matches(plan)
          definition_matches(plan).filter do |resource_change|
            change = resource_change.change
            after = change.after_object
            @attributes.all? do |attribute|
              matcher = attribute_matcher(attribute)
              value = attribute_value(after, attribute)
              matcher.matches?(value)
            end
          end
        end

        def attribute_matcher(attribute)
          expected = attribute[:value]
          return expected if expected.respond_to?(:matches?)

          RSpec::Matchers::BuiltIn::Eq.new(
            RubyTerraform::Models::Objects.box(expected)
          )
        end

        def attribute_value(object, attribute)
          expected = attribute[:value]
          actual = object.dig(*attribute[:path])
          return actual&.value if expected.respond_to?(:matches?)

          actual
        end
      end
    end
  end
end

# RSpec::Matchers.define :include_resource_creation do |type|
#   match do |plan|
#     resource_changes = plan.resource_changes_with_type(type)
#     resource_creations = resource_changes.filter(&:create?)
#
#     return false if @count && resource_creations.length != @count
#     return false if resource_creations.empty?
#
#     pp plan.to_h
#
#     if @arguments
#       return resource_creations.any? do |resource_creation|
#         @arguments.all? do |name, value|
#           resource_creation.change.after[name] == value
#         end
#       end
#     end
#
#     return true
#   end
#
#   chain :count do |count|
#     @count = count
#   end
#
#   chain :with_argument_value do |name, value|
#     @arguments = (@arguments || {}).merge(name => value)
#   end
#
#   failure_message do |plan|
#     resource_creations = plan.resource_creations.map do |resource_creation|
#       "#{resource_creation.type}.#{resource_creation.name}"
#     end
#     "\nexpected: a plan with a resource creation for type: #{type}" \
#       "\n     got: a plan with resource creations:" \
#       "\n            - #{resource_creations.join("\n            - ")}"
#   end
#
#   failure_message_when_negated do |plan|
#     resource_creations = plan.resource_creations.map do |resource_creation|
#       "#{resource_creation.type}.#{resource_creation.name}"
#     end
#     "\nexpected: a plan without a resource creation for type: #{type}" \
#       "\n     got: a plan with resource creations:" \
#       "\n            - #{resource_creations.join("\n            - ")}"
#   end
# end
