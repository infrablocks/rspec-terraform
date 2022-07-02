# frozen_string_literal: true

require 'spec_helper'

require_relative '../../../support/build'
require_relative '../../../support/random'

describe RSpec::Terraform::Matchers::IncludeResourceChange do
  describe 'without definition' do
    it 'matches when plan includes a single resource change' do
      plan = RubyTerraform::Models::Plan.new(
        Support::Build.plan_content(
          resource_changes: [
            Support::Build.resource_change_content(
              change: Support::Build.delete_change_content
            )
          ]
        )
      )

      matcher = described_class.new

      expect(matcher.matches?(plan)).to(be(true))
    end

    it 'matches when plan includes many resource changes' do
      plan = RubyTerraform::Models::Plan.new(
        Support::Build.plan_content(
          resource_changes: [
            Support::Build.resource_change_content(
              change: Support::Build.create_change_content
            ),
            Support::Build.resource_change_content(
              change: Support::Build.delete_change_content
            )
          ]
        )
      )

      matcher = described_class.new

      expect(matcher.matches?(plan)).to(be(true))
    end

    it 'mismatches when plan does not include any resource changes' do
      plan = RubyTerraform::Models::Plan.new(
        Support::Build.plan_content(
          resource_changes: []
        )
      )

      matcher = described_class.new

      expect(matcher.matches?(plan)).to(be(false))
    end
  end

  describe 'with type defined' do
    it 'matches when plan includes a single resource change with type' do
      plan = RubyTerraform::Models::Plan.new(
        Support::Build.plan_content(
          resource_changes: [
            Support::Build.resource_change_content(
              type: 'some_resource_type',
              change: Support::Build.create_change_content
            ),
            Support::Build.resource_change_content(
              type: 'other_resource_type',
              change: Support::Build.delete_change_content
            )
          ]
        )
      )

      matcher = described_class.new(type: 'some_resource_type')

      expect(matcher.matches?(plan)).to(be(true))
    end

    it 'matches when plan includes many resource changes with type' do
      plan = RubyTerraform::Models::Plan.new(
        Support::Build.plan_content(
          resource_changes: [
            Support::Build.resource_change_content(
              type: 'some_resource_type',
              change: Support::Build.create_change_content
            ),
            Support::Build.resource_change_content(
              type: 'some_resource_type',
              change: Support::Build.update_change_content
            )
          ]
        )
      )

      matcher = described_class.new(type: 'some_resource_type')

      expect(matcher.matches?(plan)).to(be(true))
    end

    it 'mismatches when plan does not include a resource change with type' do
      plan = RubyTerraform::Models::Plan.new(
        Support::Build.plan_content(
          resource_changes: [
            Support::Build.resource_change_content(
              type: 'other_resource_type1',
              change: Support::Build.create_change_content
            ),
            Support::Build.resource_change_content(
              type: 'other_resource_type2',
              change: Support::Build.create_change_content
            )
          ]
        )
      )

      matcher = described_class.new(type: 'some_resource_type')

      expect(matcher.matches?(plan)).to(be(false))
    end
  end

  describe 'with type and name defined' do
    it 'matches when plan includes a single resource change with ' \
       'type and name' do
      plan = RubyTerraform::Models::Plan.new(
        Support::Build.plan_content(
          resource_changes: [
            Support::Build.resource_change_content(
              type: 'some_resource_type',
              name: 'some_instance',
              change: Support::Build.create_change_content
            ),
            Support::Build.resource_change_content(
              type: 'some_resource_type',
              name: 'other_instance',
              change: Support::Build.update_change_content
            )
          ]
        )
      )

      matcher = described_class.new(
        type: 'some_resource_type',
        name: 'some_instance'
      )

      expect(matcher.matches?(plan)).to(be(true))
    end

    it 'matches when plan includes many resource changes with ' \
       'type and name' do
      plan = RubyTerraform::Models::Plan.new(
        Support::Build.plan_content(
          resource_changes: [
            Support::Build.resource_change_content(
              type: 'some_resource_type',
              name: 'some_instance',
              change: Support::Build.create_change_content
            ),
            Support::Build.resource_change_content(
              type: 'some_resource_type',
              name: 'some_instance',
              change: Support::Build.update_change_content
            )
          ]
        )
      )

      matcher = described_class.new(
        type: 'some_resource_type',
        name: 'some_instance'
      )

      expect(matcher.matches?(plan)).to(be(true))
    end

    it 'mismatches when plan does not include a resource change with ' \
       'type and name' do
      plan = RubyTerraform::Models::Plan.new(
        Support::Build.plan_content(
          resource_changes: [
            Support::Build.resource_change_content(
              type: 'some_resource_type',
              name: 'other_instance',
              change: Support::Build.create_change_content
            ),
            Support::Build.resource_change_content(
              type: 'other_resource_type',
              name: 'some_instance',
              change: Support::Build.delete_change_content
            )
          ]
        )
      )

      matcher = described_class.new(
        type: 'some_resource_type',
        name: 'some_instance'
      )

      expect(matcher.matches?(plan)).to(be(false))
    end
  end

  describe 'with type, name and index defined' do
    it 'matches when plan includes a single resource change with ' \
       'type, name and index' do
      plan = RubyTerraform::Models::Plan.new(
        Support::Build.plan_content(
          resource_changes: [
            Support::Build.resource_change_content(
              type: 'some_resource_type',
              name: 'some_instance',
              index: 0,
              change: Support::Build.create_change_content
            ),
            Support::Build.resource_change_content(
              type: 'some_resource_type',
              name: 'some_instance',
              index: 1,
              change: Support::Build.create_change_content
            )
          ]
        )
      )

      matcher = described_class.new(
        type: 'some_resource_type',
        name: 'some_instance',
        index: 0
      )

      expect(matcher.matches?(plan)).to(be(true))
    end

    it 'mismatches when plan does not include a resource change with ' \
       'type, name and index' do
      plan = RubyTerraform::Models::Plan.new(
        Support::Build.plan_content(
          resource_changes: [
            Support::Build.resource_change_content(
              type: 'some_resource_type',
              name: 'some_instance',
              index: 0,
              change: Support::Build.create_change_content
            ),
            Support::Build.resource_change_content(
              type: 'some_resource_type',
              name: 'some_instance',
              index: 1,
              change: Support::Build.create_change_content
            )
          ]
        )
      )

      matcher = described_class.new(
        type: 'some_resource_type',
        name: 'some_instance',
        index: 3
      )

      expect(matcher.matches?(plan)).to(be(false))
    end
  end
end
