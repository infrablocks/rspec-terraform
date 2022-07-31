# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/NestedGroups
# rubocop:disable Layout/LineContinuationLeadingSpace
describe RSpec::Terraform::Matchers::IncludeResourceChange do
  describe 'definitions' do
    describe 'without definition' do
      describe '#matches?' do
        it 'matches when plan includes a single resource change' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_deletion
                   .build

          matcher = described_class.new

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'matches when plan includes many resource changes' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation
                   .with_resource_deletion
                   .build

          matcher = described_class.new

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'mismatches when plan does not include any resource changes' do
          plan = Support::Builders
                   .plan_builder
                   .with_no_resource_changes
                   .build

          matcher = described_class.new

          expect(matcher.matches?(plan)).to(be(false))
        end
      end

      describe '#failure_message' do
        it 'indicates that resource changes were expected but ' \
           'there were none' do
          plan = Support::Builders
                   .plan_builder
                   .with_no_resource_changes
                   .build

          matcher = described_class.new
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(
              include('expected: a plan including at least one resource change')
                .and(include('got: a plan including no resource changes'))
            )
        end
      end

      describe '#failure_message_when_negated' do
        it 'indicates that resource changes were not expected but ' \
           'there were some' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation
                   .with_resource_deletion
                   .build

          matcher = described_class.new
          matcher.matches?(plan)

          expect(matcher.failure_message_when_negated)
            .to(
              include('expected: a plan including no resource changes')
                .and(include('got: a plan including at least one resource ' \
                             'change'))
            )
        end
      end
    end

    describe 'with type defined' do
      describe '#matches?' do
        it 'matches when plan includes a single resource change with type' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_deletion(type: 'other_resource_type')
                   .build

          matcher = described_class.new(type: 'some_resource_type')

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'matches when plan includes many resource changes with type' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_update(type: 'some_resource_type')
                   .build

          matcher = described_class.new(type: 'some_resource_type')

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'mismatches when plan does not include a resource change with ' \
           'type' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'other_resource_type1')
                   .with_resource_creation(type: 'other_resource_type2')
                   .build

          matcher = described_class.new(type: 'some_resource_type')

          expect(matcher.matches?(plan)).to(be(false))
        end
      end

      describe '#failure_message' do
        it 'includes the expected resource change definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'other_resource_type')
                   .with_resource_update(type: 'other_resource_type')
                   .build

          matcher = described_class.new(type: 'some_resource_type')
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(
              include('expected: a plan including at least one ' \
                      "resource change matching definition:\n" \
                      '            type = "some_resource_type"')
            )
        end

        it 'indicates there are no resource changes when none are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_no_resource_changes
                   .build

          matcher = described_class.new(type: 'some_resource_type')
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including no resource changes'))
        end

        it 'indicates there are no matching resource changes when some ' \
           'are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(
                     type: 'other_resource_type',
                     name: 'first'
                   )
                   .with_resource_update(
                     type: 'other_resource_type',
                     name: 'second'
                   )
                   .build

          matcher = described_class.new(type: 'some_resource_type')
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including no matching resource changes'))
        end

        it 'includes details of the available resource changes when some ' \
           'are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(
                     type: 'other_resource_type',
                     name: 'first'
                   )
                   .with_resource_update(
                     type: 'other_resource_type',
                     name: 'second'
                   )
                   .build

          matcher = described_class.new(type: 'some_resource_type')
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(
              include(
                "available resource changes are:\n" \
                "            - other_resource_type.first (create)\n" \
                '            - other_resource_type.second (update)'
              )
            )
        end
      end
    end

    describe 'with type and name defined' do
      describe '#matches?' do
        it 'matches when plan includes a single resource change with ' \
           'type and name' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type',
                                           name: 'some_instance')
                   .with_resource_update(type: 'some_resource_type',
                                         name: 'other_instance')
                   .build

          matcher = described_class.new(
            type: 'some_resource_type',
            name: 'some_instance'
          )

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'matches when plan includes many resource changes with ' \
           'type and name' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type',
                                           name: 'some_instance')
                   .with_resource_update(type: 'some_resource_type',
                                         name: 'some_instance')
                   .build

          matcher = described_class.new(
            type: 'some_resource_type',
            name: 'some_instance'
          )

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'mismatches when plan does not include a resource change with ' \
           'type and name' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type',
                                           name: 'other_instance')
                   .with_resource_deletion(type: 'other_resource_type',
                                           name: 'some_instance')
                   .build

          matcher = described_class.new(
            type: 'some_resource_type',
            name: 'some_instance'
          )

          expect(matcher.matches?(plan)).to(be(false))
        end
      end

      describe '#failure_message' do
        it 'includes the expected resource change definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(
                     type: 'other_resource_type',
                     name: 'first'
                   )
                   .with_resource_update(
                     type: 'other_resource_type',
                     name: 'second'
                   )
                   .build

          matcher = described_class.new(
            type: 'some_resource_type',
            name: 'some_resource_name'
          )
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(
              include('expected: a plan including at least one ' \
                      "resource change matching definition:\n" \
                      "            type = \"some_resource_type\"\n" \
                      "            name = \"some_resource_name\"\n")
            )
        end

        it 'indicates there are no resource changes when none are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_no_resource_changes
                   .build

          matcher = described_class.new(
            type: 'some_resource_type',
            name: 'some_resource_name'
          )
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including no resource changes'))
        end

        it 'indicates there are no matching resource changes when some ' \
           'are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(
                     type: 'other_resource_type',
                     name: 'first'
                   )
                   .with_resource_update(
                     type: 'other_resource_type',
                     name: 'second'
                   )
                   .build

          matcher = described_class.new(
            type: 'some_resource_type',
            name: 'some_resource_name'
          )
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including no matching resource changes'))
        end

        it 'includes details of the available resource changes when some ' \
           'are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(
                     type: 'other_resource_type',
                     name: 'first'
                   )
                   .with_resource_update(
                     type: 'other_resource_type',
                     name: 'second'
                   )
                   .build

          matcher = described_class.new(
            type: 'some_resource_type',
            name: 'some_resource_name'
          )
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(
              include(
                "available resource changes are:\n" \
                "            - other_resource_type.first (create)\n" \
                '            - other_resource_type.second (update)'
              )
            )
        end
      end
    end

    describe 'with type, name and index defined' do
      describe '#matches?' do
        it 'matches when plan includes a single resource change with ' \
           'type, name and index' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type',
                                           name: 'some_instance',
                                           index: 0)
                   .with_resource_creation(type: 'some_resource_type',
                                           name: 'some_instance',
                                           index: 1)
                   .build

          matcher = described_class.new(
            type: 'some_resource_type',
            name: 'some_instance',
            index: 0
          )

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'mismatches when plan does not include a resource change with ' \
           'type, name and index' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type',
                                           name: 'some_instance',
                                           index: 0)
                   .with_resource_creation(type: 'some_resource_type',
                                           name: 'some_instance',
                                           index: 1)
                   .build

          matcher = described_class.new(
            type: 'some_resource_type',
            name: 'some_instance',
            index: 3
          )

          expect(matcher.matches?(plan)).to(be(false))
        end
      end

      describe '#failure_message' do
        it 'includes the expected resource change definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(
                     type: 'other_resource_type',
                     name: 'first',
                     index: 0
                   )
                   .with_resource_update(
                     type: 'other_resource_type',
                     name: 'second',
                     index: 0
                   )
                   .build

          matcher = described_class.new(
            type: 'some_resource_type',
            name: 'some_resource_name',
            index: 1
          )
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(
              include('expected: a plan including at least one ' \
                      "resource change matching definition:\n" \
                      "            type = \"some_resource_type\"\n" \
                      "            name = \"some_resource_name\"\n" \
                      "            index = 1\n")
            )
        end

        it 'indicates there are no resource changes when none are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_no_resource_changes
                   .build

          matcher = described_class.new(
            type: 'some_resource_type',
            name: 'some_resource_name',
            index: 0
          )
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including no resource changes'))
        end

        it 'indicates there are no matching resource changes when some ' \
           'are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(
                     type: 'other_resource_type',
                     name: 'first',
                     index: 0
                   )
                   .with_resource_update(
                     type: 'other_resource_type',
                     name: 'second',
                     index: 0
                   )
                   .build

          matcher = described_class.new(
            type: 'some_resource_type',
            name: 'some_resource_name',
            index: 1
          )
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including no matching resource changes'))
        end

        it 'includes details of the available resource changes when some ' \
           'are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(
                     type: 'other_resource_type',
                     name: 'first',
                     index: 0
                   )
                   .with_resource_update(
                     type: 'other_resource_type',
                     name: 'second',
                     index: 0
                   )
                   .build

          matcher = described_class.new(
            type: 'some_resource_type',
            name: 'some_resource_name',
            index: 1
          )
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(
              include(
                "available resource changes are:\n" \
                "            - other_resource_type.first[0] (create)\n" \
                '            - other_resource_type.second[0] (update)'
              )
            )
        end
      end
    end
  end

  describe 'cardinality' do
    describe '#once' do
      describe '#matches?' do
        it 'matches when a single resource change meets definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_deletion(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .once

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'mismatches when no resource changes meet definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'other_resource_type')
                   .with_resource_deletion(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .once

          expect(matcher.matches?(plan)).to(be(false))
        end

        it 'mismatches when multiple resource changes meet definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_deletion(type: 'some_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .once

          expect(matcher.matches?(plan)).to(be(false))
        end
      end

      describe '#failure_message' do
        it 'includes the expected cardinality of "exactly one"' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'other_resource_type')
                   .with_resource_update(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .once
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(
              include('expected: a plan including exactly one resource change')
            )
        end

        it 'indicates there are no resource changes when none are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_no_resource_changes
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .once
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including no resource changes'))
        end

        it 'indicates there are no matching resource changes when some ' \
           'are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'other_resource_type')
                   .with_resource_update(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .once
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including no matching resource changes'))
        end

        it 'indicates there are multiple matching resource changes when more ' \
           'than one is present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_update(type: 'some_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .once
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including two matching resource changes'))
        end

        it 'includes details of the available resource changes when some ' \
           'are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(
                     type: 'other_resource_type',
                     name: 'first'
                   )
                   .with_resource_update(
                     type: 'other_resource_type',
                     name: 'second'
                   )
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .once
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(
              include(
                "available resource changes are:\n" \
                "            - other_resource_type.first (create)\n" \
                '            - other_resource_type.second (update)'
              )
            )
        end
      end
    end

    describe '#twice' do
      describe '#matches?' do
        it 'matches when two resource changes meet definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_deletion(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .twice

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'mismatches when no resource changes meet definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'other_resource_type')
                   .with_resource_deletion(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .twice

          expect(matcher.matches?(plan)).to(be(false))
        end

        it 'mismatches when one resource change meets definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_deletion(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .twice

          expect(matcher.matches?(plan)).to(be(false))
        end

        it 'mismatches when more than two resource changes meet definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_deletion(type: 'some_resource_type')
                   .with_resource_deletion(type: 'some_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .twice

          expect(matcher.matches?(plan)).to(be(false))
        end
      end

      describe '#failure_message' do
        it 'includes the expected cardinality of "exactly two"' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'other_resource_type')
                   .with_resource_update(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .twice
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(
              include('expected: a plan including exactly two resource changes')
            )
        end

        it 'indicates there are no resource changes when none are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_no_resource_changes
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .twice
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including no resource changes'))
        end

        it 'indicates there are no matching resource changes when some ' \
           'are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'other_resource_type')
                   .with_resource_update(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .twice
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including no matching resource changes'))
        end

        it 'indicates there is only one matching resource change when one ' \
           'is present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_update(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .twice
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including one matching resource change'))
        end

        it 'indicates there are multiple matching resource changes when more ' \
           'than two are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_update(type: 'some_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .twice
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include(
                  'got: a plan including three matching resource changes'
                ))
        end

        it 'includes details of the available resource changes when some ' \
           'are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(
                     type: 'other_resource_type',
                     name: 'first'
                   )
                   .with_resource_update(
                     type: 'other_resource_type',
                     name: 'second'
                   )
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .twice
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(
              include(
                "available resource changes are:\n" \
                "            - other_resource_type.first (create)\n" \
                '            - other_resource_type.second (update)'
              )
            )
        end
      end
    end

    describe '#thrice' do
      describe '#matches?' do
        it 'matches when three resource changes meet definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_deletion(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .thrice

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'mismatches when no resource changes meet definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'other_resource_type')
                   .with_resource_deletion(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .thrice

          expect(matcher.matches?(plan)).to(be(false))
        end

        it 'mismatches when less than three resource changes meet definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_deletion(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .thrice

          expect(matcher.matches?(plan)).to(be(false))
        end

        it 'mismatches when more than three resource changes meet definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_deletion(type: 'some_resource_type')
                   .with_resource_deletion(type: 'some_resource_type')
                   .with_resource_deletion(type: 'some_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .thrice

          expect(matcher.matches?(plan)).to(be(false))
        end
      end

      describe '#failure_message' do
        it 'includes the expected cardinality of "exactly three"' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'other_resource_type')
                   .with_resource_update(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .thrice
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include(
                  'expected: a plan including exactly three resource changes'
                ))
        end

        it 'indicates there are no resource changes when none are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_no_resource_changes
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .thrice
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including no resource changes'))
        end

        it 'indicates there are no matching resource changes when some ' \
           'are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'other_resource_type')
                   .with_resource_update(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .thrice
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including no matching resource changes'))
        end

        it 'indicates there is only one matching resource change when one ' \
           'is present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_update(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .thrice
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including one matching resource change'))
        end

        it 'indicates there are only two matching resource change when two ' \
           'are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_update(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .thrice
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including two matching resource changes'))
        end

        it 'indicates there are multiple matching resource changes when more ' \
           'than three are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_update(type: 'some_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .thrice
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include(
                  'got: a plan including 4 matching resource changes'
                ))
        end

        it 'includes details of the available resource changes when some ' \
           'are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(
                     type: 'other_resource_type',
                     name: 'first'
                   )
                   .with_resource_update(
                     type: 'other_resource_type',
                     name: 'second'
                   )
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .thrice
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(
              include(
                "available resource changes are:\n" \
                "            - other_resource_type.first (create)\n" \
                '            - other_resource_type.second (update)'
              )
            )
        end
      end
    end

    describe '#exactly' do
      describe '#matches?' do
        it 'matches when specified number of resource changes ' \
           'meet definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_deletion(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .exactly(4)
                      .times

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'mismatches when no resource changes meet definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'other_resource_type')
                   .with_resource_deletion(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .exactly(4)
                      .times

          expect(matcher.matches?(plan)).to(be(false))
        end

        it 'mismatches when less than specified number of resource changes ' \
           'meet definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_deletion(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .exactly(4)
                      .times

          expect(matcher.matches?(plan)).to(be(false))
        end

        it 'mismatches when more than specified number of resource changes ' \
           'meet definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_deletion(type: 'some_resource_type')
                   .with_resource_deletion(type: 'some_resource_type')
                   .with_resource_deletion(type: 'some_resource_type')
                   .with_resource_deletion(type: 'some_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .exactly(4)
                      .times

          expect(matcher.matches?(plan)).to(be(false))
        end
      end

      describe '#failure_message' do
        it 'includes the expected cardinality of "exactly <n>"' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'other_resource_type')
                   .with_resource_update(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .exactly(4).times
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include(
                  'expected: a plan including exactly 4 resource changes'
                ))
        end

        it 'indicates there are no resource changes when none are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_no_resource_changes
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .exactly(4).times
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including no resource changes'))
        end

        it 'indicates there are no matching resource changes when some ' \
           'are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'other_resource_type')
                   .with_resource_update(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .exactly(4).times
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including no matching resource changes'))
        end

        it 'indicates there is too few matching resource changes when less ' \
           'than required are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_update(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .exactly(4).times
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including one matching resource change'))
        end

        it 'indicates there are too many matching resource changes when more ' \
           'than required are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_update(type: 'some_resource_type')
                   .with_resource_update(type: 'some_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .exactly(4).times
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include(
                  'got: a plan including 5 matching resource changes'
                ))
        end

        it 'includes details of the available resource changes when some ' \
           'are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(
                     type: 'other_resource_type',
                     name: 'first'
                   )
                   .with_resource_update(
                     type: 'other_resource_type',
                     name: 'second'
                   )
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .exactly(4).times
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(
              include(
                "available resource changes are:\n" \
                "            - other_resource_type.first (create)\n" \
                '            - other_resource_type.second (update)'
              )
            )
        end
      end
    end

    describe '#at_most' do
      describe '#matches?' do
        it 'matches when specified number of resource changes ' \
           'meet definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_deletion(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .at_most(4)
                      .times

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'matches when no resource changes meet definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'other_resource_type')
                   .with_resource_deletion(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .at_most(4)
                      .times

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'matches when less than specified number of resource changes ' \
           'meet definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_deletion(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .at_most(4)
                      .times

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'mismatches when more than specified number of resource changes ' \
           'meet definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_deletion(type: 'some_resource_type')
                   .with_resource_deletion(type: 'some_resource_type')
                   .with_resource_deletion(type: 'some_resource_type')
                   .with_resource_deletion(type: 'some_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .at_most(4)
                      .times

          expect(matcher.matches?(plan)).to(be(false))
        end
      end

      describe '#failure_message' do
        it 'includes the expected cardinality of "at most <n>"' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_update(type: 'some_resource_type')
                   .with_resource_update(type: 'some_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .at_most(2).times
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include(
                  'expected: a plan including at most two resource changes'
                ))
        end

        it 'indicates there are no resource changes when none are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_no_resource_changes
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .at_most(2).times
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including no resource changes'))
        end

        it 'indicates there are no matching resource changes when some ' \
           'are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'other_resource_type')
                   .with_resource_update(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .at_most(2).times
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including no matching resource changes'))
        end

        it 'indicates there are too many matching resource changes when more ' \
           'than required are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_update(type: 'some_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .at_most(2).times
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include(
                  'got: a plan including 4 matching resource changes'
                ))
        end

        it 'includes details of the available resource changes when some ' \
           'are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(
                     type: 'other_resource_type',
                     name: 'first'
                   )
                   .with_resource_update(
                     type: 'other_resource_type',
                     name: 'second'
                   )
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .at_most(2).times
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(
              include(
                "available resource changes are:\n" \
                "            - other_resource_type.first (create)\n" \
                '            - other_resource_type.second (update)'
              )
            )
        end
      end
    end

    describe '#at_least' do
      describe '#matches?' do
        it 'matches when specified number of resource changes ' \
           'meet definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_deletion(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .at_least(2)
                      .times

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'mismatches when no resource changes meet definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'other_resource_type')
                   .with_resource_deletion(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .at_least(2)
                      .times

          expect(matcher.matches?(plan)).to(be(false))
        end

        it 'mismatches when less than specified number of resource changes ' \
           'meet definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_deletion(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .at_least(2)
                      .times

          expect(matcher.matches?(plan)).to(be(false))
        end

        it 'matches when more than specified number of resource changes ' \
           'meet definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_deletion(type: 'some_resource_type')
                   .with_resource_deletion(type: 'some_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .at_least(2)
                      .times

          expect(matcher.matches?(plan)).to(be(true))
        end
      end

      describe '#failure_message' do
        it 'includes the expected cardinality of "at least <n>"' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_update(type: 'some_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .at_least(3).times
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include(
                  'expected: a plan including at least three resource changes'
                ))
        end

        it 'indicates there are no resource changes when none are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_no_resource_changes
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .at_least(3).times
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including no resource changes'))
        end

        it 'indicates there are no matching resource changes when some ' \
           'are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'other_resource_type')
                   .with_resource_update(type: 'other_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .at_least(3).times
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including no matching resource changes'))
        end

        it 'indicates there are too few matching resource changes when less ' \
           'than required are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(type: 'some_resource_type')
                   .with_resource_update(type: 'some_resource_type')
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .at_least(3).times
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include(
                  'got: a plan including two matching resource changes'
                ))
        end

        it 'includes details of the available resource changes when some ' \
           'are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_resource_creation(
                     type: 'other_resource_type',
                     name: 'first'
                   )
                   .with_resource_update(
                     type: 'other_resource_type',
                     name: 'second'
                   )
                   .build

          matcher = described_class
                      .new(type: 'some_resource_type')
                      .at_least(3).times
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(
              include(
                "available resource changes are:\n" \
                "            - other_resource_type.first (create)\n" \
                '            - other_resource_type.second (update)'
              )
            )
        end
      end
    end
  end

  describe 'attributes' do
    describe '#with_attribute_value' do
      context 'when attribute selector is a symbol' do
        describe '#matches?' do
          it 'matches when resource change has top-level after attribute ' \
             'with name as specified by symbol and matching value' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: 'some-value'
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(:some_attribute, 'some-value')

            expect(matcher.matches?(plan)).to(be(true))
          end

          it 'mismatches when resource change has top-level after attribute ' \
             'with name as specified by symbol and mismatching value' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: 'other-value'
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(:some_attribute, 'some-value')

            expect(matcher.matches?(plan)).to(be(false))
          end

          it 'mismatches when resource change does not have top-level after ' \
             'attribute with name as specified by symbol' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           other_attribute: 'some-value'
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(:some_attribute, 'some-value')

            expect(matcher.matches?(plan)).to(be(false))
          end
        end

        describe '#failure_message' do
          it 'includes the expected attribute at the top-level' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_creation(type: 'other_resource_type')
                     .with_resource_update(type: 'other_resource_type')
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(:some_attribute, 'some-value')
            matcher.matches?(plan)

            expect(matcher.failure_message)
              .to(
                include('with attribute values after the resource change is ' \
                        'applied of:' \
                        "\n            some_attribute = \"some-value\"")
              )
          end

          it 'indicates there are no resource changes when none are present' do
            plan = Support::Builders
                     .plan_builder
                     .with_no_resource_changes
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(:some_attribute, 'some-value')
            matcher.matches?(plan)

            expect(matcher.failure_message)
              .to(include('got: a plan including no resource changes'))
          end

          it 'indicates there are no matching resource changes when some ' \
             'are present' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: 'other-value'
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(:some_attribute, 'some-value')
            matcher.matches?(plan)

            expect(matcher.failure_message)
              .to(include('got: a plan including no matching resource changes'))
          end

          it 'includes details of the relevant resource changes when some ' \
             'matching the definition are present' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_creation(
                       type: 'some_resource_type',
                       name: 'first',
                       change: {
                         after: {
                           some_attribute: 'other-value-1'
                         },
                         after_unknown: {}
                       }
                     )
                     .with_resource_update(
                       type: 'some_resource_type',
                       name: 'second',
                       change: {
                         after: {
                           some_attribute: 'other-value-2'
                         },
                         after_unknown: {}
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(:some_attribute, 'some-value')
            matcher.matches?(plan)

            expect(matcher.failure_message)
              .to(
                include(
                  "relevant resource changes are:\n" \
                  "            - some_resource_type.first (create)\n" \
                  "                some_attribute = \"other-value-1\"\n" \
                  "            - some_resource_type.second (update)\n" \
                  "                some_attribute = \"other-value-2\"\n"
                )
              )
          end

          it 'includes details of the available resource changes when some ' \
             'are present' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_creation(
                       type: 'other_resource_type',
                       name: 'first'
                     )
                     .with_resource_update(
                       type: 'other_resource_type',
                       name: 'second'
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(:some_attribute, 'some-value')
            matcher.matches?(plan)

            expect(matcher.failure_message)
              .to(
                include(
                  "available resource changes are:\n" \
                  "            - other_resource_type.first (create)\n" \
                  '            - other_resource_type.second (update)'
                )
              )
          end
        end
      end

      context 'when attribute selector is a path' do
        describe '#matches?' do
          it 'matches when resource change has after attribute at ' \
             'simple path with matching value' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: {
                             some_key: 'some-value'
                           }
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          %i[some_attribute some_key], 'some-value'
                        )

            expect(matcher.matches?(plan)).to(be(true))
          end

          it 'mismatches when resource change has after attribute at ' \
             'simple path with mismatching value' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: {
                             some_key: 'other-value'
                           }
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          %i[some_attribute some_key],
                          'some-value'
                        )

            expect(matcher.matches?(plan)).to(be(false))
          end

          it 'mismatches when resource change does not have after attribute ' \
             'for start of simple path' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           other_attribute: {
                             some_key: 'some-value'
                           }
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          %i[some_attribute some_key],
                          'some-value'
                        )

            expect(matcher.matches?(plan)).to(be(false))
          end

          it 'mismatches when resource change does not have after attribute ' \
             'at end of simple path' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: {
                             other_key: 'some-value'
                           }
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          %i[some_attribute some_key],
                          'some-value'
                        )

            expect(matcher.matches?(plan)).to(be(false))
          end
        end

        describe '#failure_message' do
          it 'includes the expected attribute as a nested map for a ' \
             'simple path' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_creation(type: 'other_resource_type')
                     .with_resource_update(type: 'other_resource_type')
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          %i[some_attribute some_key],
                          'some-value'
                        )
            matcher.matches?(plan)

            expect(matcher.failure_message)
              .to(
                include('with attribute values after the resource change is ' \
                        'applied of:' \
                        "\n            some_attribute = {" \
                        "\n              some_key = \"some-value\"" \
                        "\n            }")
              )
          end

          it 'includes the expected attribute as a nested map for a ' \
             'complex path' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_creation(type: 'other_resource_type')
                     .with_resource_update(type: 'other_resource_type')
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          [:some_attribute, 0, :some_key, 1],
                          'some-value'
                        )
            matcher.matches?(plan)

            expect(matcher.failure_message)
              .to(
                include('with attribute values after the resource change is ' \
                        'applied of:' \
                        "\n            some_attribute = [" \
                        "\n              {" \
                        "\n                some_key = [" \
                        "\n                  ...," \
                        "\n                  \"some-value\"" \
                        "\n                ]" \
                        "\n              }" \
                        "\n            ]")
              )
          end

          it 'indicates there are no resource changes when none are present' do
            plan = Support::Builders
                     .plan_builder
                     .with_no_resource_changes
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          %i[some_attribute some_key],
                          'some-value'
                        )
            matcher.matches?(plan)

            expect(matcher.failure_message)
              .to(include('got: a plan including no resource changes'))
          end

          it 'indicates there are no matching resource changes when some ' \
             'are present' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: {
                             some_key: 'other-value'
                           }
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          %i[some_attribute some_key],
                          'some-value'
                        )
            matcher.matches?(plan)

            expect(matcher.failure_message)
              .to(include('got: a plan including no matching resource changes'))
          end

          it 'includes details of the relevant resource changes when some ' \
             'matching the definition are present' do
            plan =
              Support::Builders
                .plan_builder
                .with_resource_creation(
                  type: 'some_resource_type',
                  name: 'first',
                  change: {
                    after: { some_attribute: { some_key: 'other-value-1' } },
                    after_unknown: {}
                  }
                )
                .with_resource_update(
                  type: 'some_resource_type',
                  name: 'second',
                  change: {
                    after: { some_attribute: { some_key: 'other-value-2' } },
                    after_unknown: {}
                  }
                )
                .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          %i[some_attribute some_key], 'some-value'
                        )
            matcher.matches?(plan)

            expect(matcher.failure_message)
              .to(
                include(
                  "relevant resource changes are:\n" \
                  "            - some_resource_type.first (create)\n" \
                  "                some_attribute = {\n" \
                  "                  some_key = \"other-value-1\"\n" \
                  "                }\n" \
                  "            - some_resource_type.second (update)\n" \
                  "                some_attribute = {\n" \
                  "                  some_key = \"other-value-2\"\n" \
                  "                }\n"
                )
              )
          end

          it 'includes details of the available resource changes when some ' \
             'are present' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_creation(
                       type: 'other_resource_type',
                       name: 'first'
                     )
                     .with_resource_update(
                       type: 'other_resource_type',
                       name: 'second'
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          %i[some_attribute some_key],
                          'some-value'
                        )
            matcher.matches?(plan)

            expect(matcher.failure_message)
              .to(
                include(
                  "available resource changes are:\n" \
                  "            - other_resource_type.first (create)\n" \
                  '            - other_resource_type.second (update)'
                )
              )
          end
        end
      end

      context 'when attribute value is a scalar' do
        describe '#matches?' do
          it 'matches when resource change has after attribute at symbol ' \
             'with specified scalar value' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: 'some-value'
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(:some_attribute, 'some-value')

            expect(matcher.matches?(plan)).to(be(true))
          end

          it 'matches when resource change has after attribute at path ' \
             'with specified scalar value' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: {
                             some_key: 'some-value'
                           }
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          %i[some_attribute some_key], 'some-value'
                        )

            expect(matcher.matches?(plan)).to(be(true))
          end

          it 'mismatches when resource change has after attribute at symbol ' \
             'with different scalar value' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: 12
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(:some_attribute, 'some-value')

            expect(matcher.matches?(plan)).to(be(false))
          end

          it 'mismatches when resource change has after attribute at path ' \
             'with different scalar value' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: {
                             some_key: 'other-value'
                           }
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          %i[some_attribute some_key],
                          'some-value'
                        )

            expect(matcher.matches?(plan)).to(be(false))
          end
        end

        describe '#failure_message' do
          it 'includes the expected attribute at the top-level' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_creation(type: 'other_resource_type')
                     .with_resource_update(type: 'other_resource_type')
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(:some_attribute, 10)
            matcher.matches?(plan)

            expect(matcher.failure_message)
              .to(
                include('with attribute values after the resource change is ' \
                        'applied of:' \
                        "\n            some_attribute = 10")
              )
          end

          it 'includes details of the relevant resource changes when some ' \
             'matching the definition are present' do
            plan =
              Support::Builders
                .plan_builder
                .with_resource_creation(
                  type: 'some_resource_type',
                  name: 'first',
                  change: {
                    after: { some_attribute: 12 },
                    after_unknown: {}
                  }
                )
                .with_resource_update(
                  type: 'some_resource_type',
                  name: 'second',
                  change: {
                    after: { some_attribute: 14 },
                    after_unknown: {}
                  }
                )
                .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(:some_attribute, 10)
            matcher.matches?(plan)

            expect(matcher.failure_message)
              .to(
                include(
                  "relevant resource changes are:\n" \
                  "            - some_resource_type.first (create)\n" \
                  "                some_attribute = 12\n" \
                  "            - some_resource_type.second (update)\n" \
                  "                some_attribute = 14\n"
                )
              )
          end
        end
      end

      context 'when attribute value is a list' do
        describe '#matches?' do
          it 'matches when resource change has after attribute at symbol' \
             'with specified list value' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: %w[some-value-1 some-value-2]
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          :some_attribute,
                          %w[some-value-1 some-value-2]
                        )

            expect(matcher.matches?(plan)).to(be(true))
          end

          it 'matches when resource change has after attribute at path ' \
             'with specified list value' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: {
                             some_key: %w[some-value-1 some-value-2]
                           }
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          %i[some_attribute some_key],
                          %w[some-value-1 some-value-2]
                        )

            expect(matcher.matches?(plan)).to(be(true))
          end

          it 'mismatches when resource change has after attribute at symbol ' \
             'with different list value' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: %w[value-1 value-2]
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(:some_attribute,
                                              %w[value-2 value-3])

            expect(matcher.matches?(plan)).to(be(false))
          end

          it 'mismatches when resource change has after attribute at path ' \
             'with different list value' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: {
                             some_key: %w[value-1 value-2]
                           }
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          %i[some_attribute some_key],
                          %w[value-2 value-3]
                        )

            expect(matcher.matches?(plan)).to(be(false))
          end
        end

        describe '#failure_message' do
          it 'includes the expected attribute as a list' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_creation(type: 'other_resource_type')
                     .with_resource_update(type: 'other_resource_type')
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(:some_attribute, %w[a b c])
            matcher.matches?(plan)

            expect(matcher.failure_message)
              .to(
                include('with attribute values after the resource change is ' \
                        'applied of:' \
                        "\n            some_attribute = [" \
                        "\n              \"a\"," \
                        "\n              \"b\"," \
                        "\n              \"c\"" \
                        "\n            ]") \
              )
          end

          it 'includes details of the relevant resource changes when some ' \
             'matching the definition are present' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_creation(
                       type: 'some_resource_type', name: 'first',
                       change: {
                         after: { some_attribute: %w[a b c] },
                         after_unknown: {}
                       }
                     )
                     .with_resource_update(
                       type: 'some_resource_type', name: 'second',
                       change: {
                         after: { some_attribute: %w[d e f] },
                         after_unknown: {}
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(:some_attribute, %w[g h i])
            matcher.matches?(plan)

            expect(matcher.failure_message)
              .to(
                include(
                  "relevant resource changes are:\n" \
                  "            - some_resource_type.first (create)\n" \
                  "                some_attribute = [\n" \
                  "                  \"a\",\n" \
                  "                  \"b\",\n" \
                  "                  \"c\"\n" \
                  "                ]\n" \
                  "            - some_resource_type.second (update)\n" \
                  "                some_attribute = [\n" \
                  "                  \"d\",\n" \
                  "                  \"e\",\n" \
                  "                  \"f\"\n" \
                  "                ]\n" \
                )
              )
          end
        end
      end

      context 'when attribute value is a map' do
        describe '#matches?' do
          it 'matches when resource change has after attribute at symbol' \
             'with specified map value' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: { first: 1, second: 2 }
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          :some_attribute,
                          { first: 1, second: 2 }
                        )

            expect(matcher.matches?(plan)).to(be(true))
          end

          it 'matches when resource change has after attribute at path ' \
             'with specified map value' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: {
                             some_key: {
                               first: 1,
                               second: 2
                             }
                           }
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          %i[some_attribute some_key],
                          { first: 1, second: 2 }
                        )

            expect(matcher.matches?(plan)).to(be(true))
          end

          it 'matches when resource change has after attribute ' \
             'map value with symbol keys for expected map value with ' \
             'string keys' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: {
                             first: 1,
                             second: 2
                           }
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          :some_attribute,
                          { 'first' => 1, 'second' => 2 }
                        )

            expect(matcher.matches?(plan)).to(be(true))
          end

          it 'mismatches when resource change has after attribute at symbol' \
             'with different map value' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: { first: 1, second: 2 }
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(:some_attribute,
                                              { second: 2, third: 3 })

            expect(matcher.matches?(plan)).to(be(false))
          end

          it 'mismatches when resource change has after attribute at path ' \
             'with different map value' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: {
                             some_key: { first: 1, second: 2 }
                           }
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          %i[some_attribute some_key],
                          { second: 2, third: 3 }
                        )

            expect(matcher.matches?(plan)).to(be(false))
          end
        end

        describe '#failure_message' do
          it 'includes the expected attribute as a map' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_creation(type: 'other_resource_type')
                     .with_resource_update(type: 'other_resource_type')
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          :some_attribute,
                          {
                            some_key: 123
                          }
                        )
            matcher.matches?(plan)

            expect(matcher.failure_message)
              .to(
                include('with attribute values after the resource change is ' \
                        'applied of:' \
                        "\n            some_attribute = {" \
                        "\n              some_key = 123" \
                        "\n            }") \
              )
          end

          it 'includes details of the relevant resource changes when some ' \
             'matching the definition are present' do
            plan =
              Support::Builders
                .plan_builder
                .with_resource_creation(
                  type: 'some_resource_type',
                  name: 'first',
                  change: {
                    after: { some_attribute: { some_key: 10 } },
                    after_unknown: {}
                  }
                )
                .with_resource_update(
                  type: 'some_resource_type',
                  name: 'second',
                  change: {
                    after: { some_attribute: { some_key: 12 } },
                    after_unknown: {}
                  }
                )
                .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          :some_attribute, { some_key: 14 }
                        )
            matcher.matches?(plan)

            expect(matcher.failure_message)
              .to(
                include(
                  "relevant resource changes are:\n" \
                  "            - some_resource_type.first (create)\n" \
                  "                some_attribute = {\n" \
                  "                  some_key = 10\n" \
                  "                }\n" \
                  "            - some_resource_type.second (update)\n" \
                  "                some_attribute = {\n" \
                  "                  some_key = 12\n" \
                  "                }\n" \
                )
              )
          end
        end
      end

      context 'when attribute value is a complex nested value' do
        describe '#matches?' do
          it 'matches when resource change has after attribute at symbol' \
             'with specified complex nested value' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: {
                             first: [{ a: 1, b: 2 }],
                             second: [3, 4, 5]
                           }
                         }
                       }
                     )
                     .build

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

          it 'matches when resource change has after attribute at path ' \
             'with specified complex nested value' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: {
                             some_key: {
                               first: [{ a: 1, b: 2 }],
                               second: [3, 4, 5]
                             }
                           }
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          %i[some_attribute some_key],
                          {
                            first: [{ a: 1, b: 2 }],
                            second: [3, 4, 5]
                          }
                        )

            expect(matcher.matches?(plan)).to(be(true))
          end

          it 'mismatches when resource change has after attribute at symbol' \
             'with different complex nested value' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: {
                             first: [{ a: 1, b: 2 }],
                             second: [3, 4, 5]
                           }
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(:some_attribute,
                                              {
                                                first: [{ a: 1, c: 3 }],
                                                second: [3, 4, 5]
                                              })

            expect(matcher.matches?(plan)).to(be(false))
          end

          it 'mismatches when resource change has after attribute at path ' \
             'with different complex nested value' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: {
                             some_key: {
                               first: [{ a: 1, b: 2 }],
                               second: [3, 4, 5]
                             }
                           }
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          %i[some_attribute some_key],
                          {
                            first: [{ a: 1, c: 3 }],
                            second: [3, 4, 5]
                          }
                        )

            expect(matcher.matches?(plan)).to(be(false))
          end
        end

        describe '#failure_message' do
          it 'includes the expected attribute as a complex nested structure' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_creation(type: 'other_resource_type')
                     .with_resource_update(type: 'other_resource_type')
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          :some_attribute,
                          {
                            first: [{ a: 1, b: 2 }],
                            second: [3, 4, 5]
                          }
                        )
            matcher.matches?(plan)

            expect(matcher.failure_message)
              .to(
                include('with attribute values after the resource change is ' \
                        'applied of:' \
                        "\n            some_attribute = {" \
                        "\n              first = [" \
                        "\n                {" \
                        "\n                  a = 1" \
                        "\n                  b = 2" \
                        "\n                }" \
                        "\n              ]" \
                        "\n              second = [" \
                        "\n                3," \
                        "\n                4," \
                        "\n                5" \
                        "\n              ]" \
                        "\n            }") \
              )
          end

          it 'includes details of the relevant resource changes when some ' \
             'matching the definition are present' do
            plan =
              Support::Builders
                .plan_builder
                .with_resource_creation(
                  type: 'some_resource_type',
                  name: 'first',
                  change: {
                    after: {
                      some_attribute: {
                        first: [{ a: 1, b: 2 }], second: [3, 4, 5]
                      }
                    },
                    after_unknown: {}
                  }
                )
                .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(:some_attribute, { some_key: 14 })
            matcher.matches?(plan)

            expect(matcher.failure_message)
              .to(
                include(
                  "relevant resource changes are:\n" \
                  "            - some_resource_type.first (create)\n" \
                  "                some_attribute = {\n" \
                  "                  first = [\n" \
                  "                    {\n" \
                  "                      a = 1\n" \
                  "                      b = 2\n" \
                  "                    }\n" \
                  "                  ]\n" \
                  "                  second = [\n" \
                  "                    3,\n" \
                  "                    4,\n" \
                  "                    5\n" \
                  "                  ]\n" \
                  "                }\n"
                )
              )
          end
        end
      end

      context 'when attribute value is a matcher' do
        describe '#matches?' do
          it 'matches when resource change has after attribute ' \
             'with scalar value satisfying specified matcher' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: 'some-value'
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          :some_attribute, including('some')
                        )

            expect(matcher.matches?(plan)).to(be(true))
          end

          it 'matches when resource change has after attribute ' \
             'with list value satisfying specified matcher' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: [1, 2, 3]
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(:some_attribute, including(2))

            expect(matcher.matches?(plan)).to(be(true))
          end

          it 'matches when resource change has after attribute ' \
             'with map value satisfying specified matcher' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: {
                             first: 1,
                             second: 2
                           }
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          :some_attribute, including(first: 1)
                        )

            expect(matcher.matches?(plan)).to(be(true))
          end

          it 'matches when resource change has after attribute ' \
             'with complex nested value satisfying specified matcher' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: {
                             some_key: [
                               {
                                 first: 1,
                                 second: 2
                               }
                             ]
                           }
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          :some_attribute,
                          including(some_key: [{ first: 1, second: 2 }])
                        )

            expect(matcher.matches?(plan)).to(be(true))
          end

          it 'mismatches when resource change has after attribute' \
             'with scalar value that does not satisfy specified matcher' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: 'some-value'
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          :some_attribute, including('other')
                        )

            expect(matcher.matches?(plan)).to(be(false))
          end

          it 'mismatches when resource change has after attribute ' \
             'with list value that does not satisfy specified matcher' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: [4, 5, 6]
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(:some_attribute, including(2))

            expect(matcher.matches?(plan)).to(be(false))
          end

          it 'mismatches when resource change has after attribute ' \
             'with map value that does not satisfy specified matcher' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: {
                             third: 3,
                             fourth: 4
                           }
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          :some_attribute, including(first: 1)
                        )

            expect(matcher.matches?(plan)).to(be(false))
          end

          it 'mismatches when resource change has after attribute ' \
             'with complex nested value that does not satisfy ' \
             'specified matcher' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_deletion(type: 'other_resource_type')
                     .with_resource_creation(
                       type: 'some_resource_type',
                       change: {
                         after: {
                           some_attribute: {
                             some_key: [
                               {
                                 third: 3,
                                 fourth: 4
                               }
                             ]
                           }
                         }
                       }
                     )
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          :some_attribute,
                          including(some_key: [{ first: 1, second: 2 }])
                        )

            expect(matcher.matches?(plan)).to(be(false))
          end
        end

        describe '#failure_message' do
          it 'includes the expected attribute using the matcher description' do
            plan = Support::Builders
                     .plan_builder
                     .with_resource_creation(type: 'other_resource_type')
                     .with_resource_update(type: 'other_resource_type')
                     .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          :some_attribute, including('some')
                        )
            matcher.matches?(plan)

            matcher_description = 'a value satisfying: including "some"'
            expect(matcher.failure_message)
              .to(
                include(
                  'with attribute values after the resource change is ' \
                  'applied of:' \
                  "\n            some_attribute = #{matcher_description}"
                )
              )
          end

          it 'includes details of the relevant resource changes when some ' \
             'matching the definition are present' do
            plan =
              Support::Builders
                .plan_builder
                .with_resource_creation(
                  type: 'some_resource_type',
                  name: 'first',
                  change: {
                    after: { some_attribute: 'other-1' },
                    after_unknown: {}
                  }
                )
                .with_resource_update(
                  type: 'some_resource_type',
                  name: 'second',
                  change: {
                    after: { some_attribute: 'other-2' },
                    after_unknown: {}
                  }
                )
                .build

            matcher = described_class
                        .new(type: 'some_resource_type')
                        .with_attribute_value(
                          :some_attribute, including('some')
                        )
            matcher.matches?(plan)

            expect(matcher.failure_message)
              .to(
                include(
                  "relevant resource changes are:\n" \
                  "            - some_resource_type.first (create)\n" \
                  "                some_attribute = \"other-1\"\n" \
                  "            - some_resource_type.second (update)\n" \
                  "                some_attribute = \"other-2\"\n"
                )
              )
          end
        end
      end
    end
  end
end
# rubocop:enable Layout/LineContinuationLeadingSpace
# rubocop:enable RSpec/NestedGroups
