# frozen_string_literal: true

require 'ruby_terraform'

module Support
  module Builders
    def self.plan_builder
      Plan.new
    end

    class Plan
      def initialize
        @resource_change_contents = []
      end

      def with_resource_change(content = {})
        @resource_change_contents << [:any, content]
        self
      end

      def with_resource_creation(content = {})
        @resource_change_contents << [:create, content]
        self
      end

      def with_resource_read(content = {})
        @resource_change_contents << [:read, content]
        self
      end

      def with_resource_update(content = {})
        @resource_change_contents << [:update, content]
        self
      end

      def with_resource_replacement(content = {})
        @resource_change_contents << [:replace, content]
        self
      end

      def with_resource_deletion(content = {})
        @resource_change_contents << [:delete, content]
        self
      end

      def with_no_resource_changes
        @resource_change_contents = []
        self
      end

      def build
        RubyTerraform::Models::Plan.new(
          Support::Build.plan_content(
            resource_changes: resource_changes
          )
        )
      end

      private

      def change_content_build_function(type)
        {
          any: Build.method(:change_content),
          create: Build.method(:create_change_content),
          read: Build.method(:read_change_content),
          update: Build.method(:update_change_content),
          replace: Build.method(:replace_change_content),
          delete: Build.method(:delete_change_content)
        }[type]
      end

      def resource_changes
        @resource_change_contents.collect do |item|
          content = item[1]
          change_type = item[0]
          change_content =
            change_content_build_function(change_type)
              .call(content[:change] || {})
          Build.resource_change_content(
            content.merge(change: change_content)
          )
        end
      end
    end
  end
end
