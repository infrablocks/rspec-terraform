# frozen_string_literal: true

require 'spec_helper'

require_relative '../../../support/build'
require_relative '../../../support/random'

# rubocop:disable RSpec/NestedGroups
describe RSpec::Terraform::Matchers::IncludeResourceChange do
  describe 'definitions' do
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

  describe 'cardinality' do
    describe '#once' do
      it 'matches when a single resource change meets definition' do
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

        matcher = described_class
                  .new(type: 'some_resource_type')
                  .once

        expect(matcher.matches?(plan)).to(be(true))
      end

      it 'mismatches when no resource changes meet definition' do
        plan = RubyTerraform::Models::Plan.new(
          Support::Build.plan_content(
            resource_changes: [
              Support::Build.resource_change_content(
                type: 'other_resource_type',
                change: Support::Build.create_change_content
              ),
              Support::Build.resource_change_content(
                type: 'other_resource_type',
                change: Support::Build.delete_change_content
              )
            ]
          )
        )

        matcher = described_class
                  .new(type: 'some_resource_type')
                  .once

        expect(matcher.matches?(plan)).to(be(false))
      end

      it 'mismatches when multiple resource change meet definition' do
        plan = RubyTerraform::Models::Plan.new(
          Support::Build.plan_content(
            resource_changes: [
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.create_change_content
              ),
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.delete_change_content
              )
            ]
          )
        )

        matcher = described_class
                  .new(type: 'some_resource_type')
                  .once

        expect(matcher.matches?(plan)).to(be(false))
      end
    end

    describe '#twice' do
      it 'matches when two resource changes meet definition' do
        plan = RubyTerraform::Models::Plan.new(
          Support::Build.plan_content(
            resource_changes: [
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.create_change_content
              ),
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

        matcher = described_class
                  .new(type: 'some_resource_type')
                  .twice

        expect(matcher.matches?(plan)).to(be(true))
      end

      it 'mismatches when no resource changes meet definition' do
        plan = RubyTerraform::Models::Plan.new(
          Support::Build.plan_content(
            resource_changes: [
              Support::Build.resource_change_content(
                type: 'other_resource_type',
                change: Support::Build.create_change_content
              ),
              Support::Build.resource_change_content(
                type: 'other_resource_type',
                change: Support::Build.delete_change_content
              )
            ]
          )
        )

        matcher = described_class
                  .new(type: 'some_resource_type')
                  .twice

        expect(matcher.matches?(plan)).to(be(false))
      end

      it 'mismatches when one resource change meets definition' do
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

        matcher = described_class
                  .new(type: 'some_resource_type')
                  .twice

        expect(matcher.matches?(plan)).to(be(false))
      end

      it 'mismatches when more than two resource changes meet definition' do
        plan = RubyTerraform::Models::Plan.new(
          Support::Build.plan_content(
            resource_changes: [
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.create_change_content
              ),
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.delete_change_content
              ),
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.delete_change_content
              )
            ]
          )
        )

        matcher = described_class
                  .new(type: 'some_resource_type')
                  .twice

        expect(matcher.matches?(plan)).to(be(false))
      end
    end

    describe '#thrice' do
      it 'matches when three resource changes meet definition' do
        plan = RubyTerraform::Models::Plan.new(
          Support::Build.plan_content(
            resource_changes: [
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.create_change_content
              ),
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.create_change_content
              ),
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

        matcher = described_class
                  .new(type: 'some_resource_type')
                  .thrice

        expect(matcher.matches?(plan)).to(be(true))
      end

      it 'mismatches when no resource changes meet definition' do
        plan = RubyTerraform::Models::Plan.new(
          Support::Build.plan_content(
            resource_changes: [
              Support::Build.resource_change_content(
                type: 'other_resource_type',
                change: Support::Build.create_change_content
              ),
              Support::Build.resource_change_content(
                type: 'other_resource_type',
                change: Support::Build.delete_change_content
              )
            ]
          )
        )

        matcher = described_class
                  .new(type: 'some_resource_type')
                  .thrice

        expect(matcher.matches?(plan)).to(be(false))
      end

      it 'mismatches when less than three resource changes meet definition' do
        plan = RubyTerraform::Models::Plan.new(
          Support::Build.plan_content(
            resource_changes: [
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.create_change_content
              ),
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

        matcher = described_class
                  .new(type: 'some_resource_type')
                  .thrice

        expect(matcher.matches?(plan)).to(be(false))
      end

      it 'mismatches when more than three resource changes meet definition' do
        plan = RubyTerraform::Models::Plan.new(
          Support::Build.plan_content(
            resource_changes: [
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.create_change_content
              ),
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.delete_change_content
              ),
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.delete_change_content
              ),
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.delete_change_content
              )
            ]
          )
        )

        matcher = described_class
                  .new(type: 'some_resource_type')
                  .thrice

        expect(matcher.matches?(plan)).to(be(false))
      end
    end

    describe '#exactly' do
      it 'matches when specified number of resource changes meet definition' do
        plan = RubyTerraform::Models::Plan.new(
          Support::Build.plan_content(
            resource_changes: [
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.create_change_content
              ),
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.create_change_content
              ),
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.create_change_content
              ),
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

        matcher = described_class
                  .new(type: 'some_resource_type')
                  .exactly(4)
                  .times

        expect(matcher.matches?(plan)).to(be(true))
      end

      it 'mismatches when no resource changes meet definition' do
        plan = RubyTerraform::Models::Plan.new(
          Support::Build.plan_content(
            resource_changes: [
              Support::Build.resource_change_content(
                type: 'other_resource_type',
                change: Support::Build.create_change_content
              ),
              Support::Build.resource_change_content(
                type: 'other_resource_type',
                change: Support::Build.delete_change_content
              )
            ]
          )
        )

        matcher = described_class
                  .new(type: 'some_resource_type')
                  .exactly(4)
                  .times

        expect(matcher.matches?(plan)).to(be(false))
      end

      it 'mismatches when less than specified number of resource changes ' \
         'meet definition' do
        plan = RubyTerraform::Models::Plan.new(
          Support::Build.plan_content(
            resource_changes: [
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.create_change_content
              ),
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

        matcher = described_class
                  .new(type: 'some_resource_type')
                  .exactly(4)
                  .times

        expect(matcher.matches?(plan)).to(be(false))
      end

      it 'mismatches when more than specified number of resource changes ' \
         'meet definition' do
        plan = RubyTerraform::Models::Plan.new(
          Support::Build.plan_content(
            resource_changes: [
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.create_change_content
              ),
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.delete_change_content
              ),
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.delete_change_content
              ),
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.delete_change_content
              ),
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.delete_change_content
              )
            ]
          )
        )

        matcher = described_class
                  .new(type: 'some_resource_type')
                  .exactly(4)
                  .times

        expect(matcher.matches?(plan)).to(be(false))
      end
    end

    describe '#at_most' do
      it 'matches when specified number of resource changes meet definition' do
        plan = RubyTerraform::Models::Plan.new(
          Support::Build.plan_content(
            resource_changes: [
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.create_change_content
              ),
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.create_change_content
              ),
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.create_change_content
              ),
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

        matcher = described_class
                  .new(type: 'some_resource_type')
                  .at_most(4)
                  .times

        expect(matcher.matches?(plan)).to(be(true))
      end

      it 'matches when no resource changes meet definition' do
        plan = RubyTerraform::Models::Plan.new(
          Support::Build.plan_content(
            resource_changes: [
              Support::Build.resource_change_content(
                type: 'other_resource_type',
                change: Support::Build.create_change_content
              ),
              Support::Build.resource_change_content(
                type: 'other_resource_type',
                change: Support::Build.delete_change_content
              )
            ]
          )
        )

        matcher = described_class
                  .new(type: 'some_resource_type')
                  .at_most(4)
                  .times

        expect(matcher.matches?(plan)).to(be(true))
      end

      it 'matches when less than specified number of resource changes ' \
         'meet definition' do
        plan = RubyTerraform::Models::Plan.new(
          Support::Build.plan_content(
            resource_changes: [
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.create_change_content
              ),
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

        matcher = described_class
                  .new(type: 'some_resource_type')
                  .at_most(4)
                  .times

        expect(matcher.matches?(plan)).to(be(true))
      end

      it 'mismatches when more than specified number of resource changes ' \
         'meet definition' do
        plan = RubyTerraform::Models::Plan.new(
          Support::Build.plan_content(
            resource_changes: [
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.create_change_content
              ),
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.delete_change_content
              ),
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.delete_change_content
              ),
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.delete_change_content
              ),
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.delete_change_content
              )
            ]
          )
        )

        matcher = described_class
                  .new(type: 'some_resource_type')
                  .at_most(4)
                  .times

        expect(matcher.matches?(plan)).to(be(false))
      end
    end

    describe '#at_least' do
      it 'matches when specified number of resource changes meet definition' do
        plan = RubyTerraform::Models::Plan.new(
          Support::Build.plan_content(
            resource_changes: [
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.create_change_content
              ),
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

        matcher = described_class
                  .new(type: 'some_resource_type')
                  .at_least(2)
                  .times

        expect(matcher.matches?(plan)).to(be(true))
      end

      it 'mismatches when no resource changes meet definition' do
        plan = RubyTerraform::Models::Plan.new(
          Support::Build.plan_content(
            resource_changes: [
              Support::Build.resource_change_content(
                type: 'other_resource_type',
                change: Support::Build.create_change_content
              ),
              Support::Build.resource_change_content(
                type: 'other_resource_type',
                change: Support::Build.delete_change_content
              )
            ]
          )
        )

        matcher = described_class
                  .new(type: 'some_resource_type')
                  .at_least(2)
                  .times

        expect(matcher.matches?(plan)).to(be(false))
      end

      it 'mismatches when less than specified number of resource changes ' \
         'meet definition' do
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

        matcher = described_class
                  .new(type: 'some_resource_type')
                  .at_least(2)
                  .times

        expect(matcher.matches?(plan)).to(be(false))
      end

      it 'matches when more than specified number of resource changes ' \
         'meet definition' do
        plan = RubyTerraform::Models::Plan.new(
          Support::Build.plan_content(
            resource_changes: [
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.create_change_content
              ),
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.delete_change_content
              ),
              Support::Build.resource_change_content(
                type: 'some_resource_type',
                change: Support::Build.delete_change_content
              )
            ]
          )
        )

        matcher = described_class
                  .new(type: 'some_resource_type')
                  .at_least(2)
                  .times

        expect(matcher.matches?(plan)).to(be(true))
      end
    end
  end

  describe 'attributes' do
    describe '#with_attribute_value' do
      context 'when before/after not specified' do
        it 'matches when resource change has after attribute with specified ' \
           'scalar value' do
          plan = RubyTerraform::Models::Plan.new(
            Support::Build.plan_content(
              resource_changes: [
                Support::Build.resource_change_content(
                  type: 'some_resource_type',
                  change: Support::Build.create_change_content(
                    {
                      after: {
                        some_attribute: 'some-value'
                      }
                    }
                  )
                ),
                Support::Build.resource_change_content(
                  type: 'other_resource_type',
                  change: Support::Build.delete_change_content
                )
              ]
            )
          )

          matcher = described_class
                    .new(type: 'some_resource_type')
                    .with_attribute_value(:some_attribute, 'some-value')

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'matches when resource change has after attribute with specified ' \
           'list value' do
          plan = RubyTerraform::Models::Plan.new(
            Support::Build.plan_content(
              resource_changes: [
                Support::Build.resource_change_content(
                  type: 'some_resource_type',
                  change: Support::Build.create_change_content(
                    {
                      after: {
                        some_attribute: %w[some-value-1 some-value-2]
                      }
                    }
                  )
                ),
                Support::Build.resource_change_content(
                  type: 'other_resource_type',
                  change: Support::Build.delete_change_content
                )
              ]
            )
          )

          matcher = described_class
                    .new(type: 'some_resource_type')
                    .with_attribute_value(
                      :some_attribute,
                      %w[some-value-1 some-value-2]
                    )

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'matches when resource change has after attribute with specified ' \
           'map value' do
          plan = RubyTerraform::Models::Plan.new(
            Support::Build.plan_content(
              resource_changes: [
                Support::Build.resource_change_content(
                  type: 'some_resource_type',
                  change: Support::Build.create_change_content(
                    {
                      after: {
                        some_attribute: { first: 1, second: 2 }
                      }
                    }
                  )
                ),
                Support::Build.resource_change_content(
                  type: 'other_resource_type',
                  change: Support::Build.delete_change_content
                )
              ]
            )
          )

          matcher = described_class
                    .new(type: 'some_resource_type')
                    .with_attribute_value(
                      :some_attribute,
                      { first: 1, second: 2 }
                    )

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'matches when resource change has after attribute with specified ' \
           'complex nested value' do
          plan = RubyTerraform::Models::Plan.new(
            Support::Build.plan_content(
              resource_changes: [
                Support::Build.resource_change_content(
                  type: 'some_resource_type',
                  change: Support::Build.create_change_content(
                    {
                      after: {
                        some_attribute: {
                          first: [{ a: 1, b: 2 }],
                          second: [3, 4, 5]
                        }
                      }
                    }
                  )
                ),
                Support::Build.resource_change_content(
                  type: 'other_resource_type',
                  change: Support::Build.delete_change_content
                )
              ]
            )
          )

          matcher = described_class
                    .new(type: 'some_resource_type')
                    .with_attribute_value(
                      :some_attribute,
                      {
                        first: [{ a: 1, b: 2 }],
                        second: [3, 4, 5]
                      }
                    )

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'mismatches when resource change has after attribute with ' \
           'different scalar value' do
          plan = RubyTerraform::Models::Plan.new(
            Support::Build.plan_content(
              resource_changes: [
                Support::Build.resource_change_content(
                  type: 'some_resource_type',
                  change: Support::Build.create_change_content(
                    {
                      after: {
                        some_attribute: 'other-value'
                      }
                    }
                  )
                ),
                Support::Build.resource_change_content(
                  type: 'other_resource_type',
                  change: Support::Build.delete_change_content
                )
              ]
            )
          )

          matcher = described_class
                    .new(type: 'some_resource_type')
                    .with_attribute_value(:some_attribute, 'some-value')

          expect(matcher.matches?(plan)).to(be(false))
        end

        it 'mismatches when resource change has after attribute with ' \
           'different list value' do
          plan = RubyTerraform::Models::Plan.new(
            Support::Build.plan_content(
              resource_changes: [
                Support::Build.resource_change_content(
                  type: 'some_resource_type',
                  change: Support::Build.create_change_content(
                    {
                      after: {
                        some_attribute: %w[value-1 value-2]
                      }
                    }
                  )
                ),
                Support::Build.resource_change_content(
                  type: 'other_resource_type',
                  change: Support::Build.delete_change_content
                )
              ]
            )
          )

          matcher = described_class
                    .new(type: 'some_resource_type')
                    .with_attribute_value(:some_attribute, %w[value-2 value-3])

          expect(matcher.matches?(plan)).to(be(false))
        end

        it 'mismatches when resource change has after attribute with ' \
           'different map value' do
          plan = RubyTerraform::Models::Plan.new(
            Support::Build.plan_content(
              resource_changes: [
                Support::Build.resource_change_content(
                  type: 'some_resource_type',
                  change: Support::Build.create_change_content(
                    {
                      after: {
                        some_attribute: { first: 1, second: 2 }
                      }
                    }
                  )
                ),
                Support::Build.resource_change_content(
                  type: 'other_resource_type',
                  change: Support::Build.delete_change_content
                )
              ]
            )
          )

          matcher = described_class
                    .new(type: 'some_resource_type')
                    .with_attribute_value(:some_attribute,
                                          { second: 2, third: 3 })

          expect(matcher.matches?(plan)).to(be(false))
        end

        it 'mismatches when resource change has after attribute with ' \
           'different complex nested value' do
          plan = RubyTerraform::Models::Plan.new(
            Support::Build.plan_content(
              resource_changes: [
                Support::Build.resource_change_content(
                  type: 'some_resource_type',
                  change: Support::Build.create_change_content(
                    {
                      after: {
                        some_attribute: {
                          first: [{ a: 1, b: 2 }],
                          second: [3, 4, 5]
                        }
                      }
                    }
                  )
                ),
                Support::Build.resource_change_content(
                  type: 'other_resource_type',
                  change: Support::Build.delete_change_content
                )
              ]
            )
          )

          matcher = described_class
                    .new(type: 'some_resource_type')
                    .with_attribute_value(:some_attribute,
                                          {
                                            first: [{ a: 1, c: 3 }],
                                            second: [3, 4, 5]
                                          })

          expect(matcher.matches?(plan)).to(be(false))
        end

        it 'mismatches when resource change does not have after attribute' do
          plan = RubyTerraform::Models::Plan.new(
            Support::Build.plan_content(
              resource_changes: [
                Support::Build.resource_change_content(
                  type: 'some_resource_type',
                  change: Support::Build.create_change_content(
                    {
                      after: {
                        other_attribute: 'some-value'
                      }
                    }
                  )
                ),
                Support::Build.resource_change_content(
                  type: 'other_resource_type',
                  change: Support::Build.delete_change_content
                )
              ]
            )
          )

          matcher = described_class
                    .new(type: 'some_resource_type')
                    .with_attribute_value(:some_attribute, 'some-value')

          expect(matcher.matches?(plan)).to(be(false))
        end
      end
    end
  end
end
# rubocop:enable RSpec/NestedGroups
