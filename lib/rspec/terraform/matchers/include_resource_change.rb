# frozen_string_literal: true

module RSpec
  module Terraform
    module Matchers
      class IncludeResourceChange
        attr_reader :definition

        def initialize(definition = {})
          @definition = definition
        end

        def matches?(plan)
          !plan.resource_changes_matching(definition).empty?
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
