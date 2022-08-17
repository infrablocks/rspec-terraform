# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/NestedGroups
# rubocop:disable Layout/LineContinuationLeadingSpace
describe RSpec::Terraform::Matchers::IncludeOutputChange do
  describe 'definitions' do
    describe 'without definition' do
      describe '#matches?' do
        it 'matches when plan includes a single output change' do
          plan = Support::Builders
                   .plan_builder
                   .with_output_creation('some_output')
                   .build

          matcher = described_class.new

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'matches when plan includes many output changes' do
          plan = Support::Builders
                   .plan_builder
                   .with_output_creation('some_output')
                   .with_output_deletion('other_output')
                   .build

          matcher = described_class.new

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'mismatches when plan does not include any output changes' do
          plan = Support::Builders
                   .plan_builder
                   .with_no_output_changes
                   .build

          matcher = described_class.new

          expect(matcher.matches?(plan)).to(be(false))
        end
      end

      describe '#failure_message' do
        it 'indicates that output changes were expected but ' \
           'there were none' do
          plan = Support::Builders
                   .plan_builder
                   .with_no_output_changes
                   .build

          matcher = described_class.new
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(
              include('expected: a plan including at least one output change')
                .and(include('got: a plan including no output changes'))
            )
        end
      end
    end

    describe 'for name' do
      describe '#matches?' do
        it 'returns true when the plan contains an output change with the ' \
           'provided name' do
          plan = Support::Builders
                   .plan_builder
                   .with_output_change('some_output')
                   .build

          matcher = described_class.new(name: 'some_output')

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'returns false when the plan does not contain an output change ' \
           'with the provided name' do
          plan = Support::Builders
                   .plan_builder
                   .with_output_change('other_output')
                   .build

          matcher = described_class.new(name: 'some_output')

          expect(matcher.matches?(plan)).to(be(false))
        end
      end

      describe '#failure_message' do
        it 'includes the expected output change definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_output_creation('other_output_1')
                   .with_output_update('other_output_2')
                   .build

          matcher = described_class.new(name: 'some_output')
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(
              include('expected: a plan including at least one ' \
                      "output change matching definition:\n" \
                      '            name = "some_output"')
            )
        end

        it 'indicates there are no output changes when none are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_no_output_changes
                   .build

          matcher = described_class.new(name: 'some_output')
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including no output changes'))
        end

        it 'indicates there are no matching output changes when some ' \
           'are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_output_creation('other_output_1')
                   .with_output_update('other_output_2')
                   .build

          matcher = described_class.new(name: 'some_output')
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including no matching output changes'))
        end

        it 'includes details of the available output changes when some ' \
           'are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_output_creation('other_output_1')
                   .with_output_update('other_output_2')
                   .build

          matcher = described_class.new(name: 'some_output')
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(
              include(
                "available output changes are:\n" \
                "            - other_output_1 (create)\n" \
                '            - other_output_2 (update)'
              )
            )
        end
      end
    end

    describe 'for name and query' do
      describe '#matches?' do
        it 'returns true when the plan contains an output change with the ' \
           'provided name and of the queried type' do
          plan = Support::Builders
                   .plan_builder
                   .with_output_creation('some_output')
                   .build

          matcher = described_class.new(
            name: 'some_output',
            create?: true
          )

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'returns false when the plan does not contain an output change ' \
           'with the provided name' do
          plan = Support::Builders
                   .plan_builder
                   .with_output_creation('other_output')
                   .build

          matcher = described_class.new(
            name: 'some_output',
            create?: true
          )

          expect(matcher.matches?(plan)).to(be(false))
        end

        it 'returns false when the plan does not contain an output change ' \
           'of the queried type' do
          plan = Support::Builders
                   .plan_builder
                   .with_output_update('some_output')
                   .build

          matcher = described_class.new(
            name: 'some_output',
            create?: true
          )

          expect(matcher.matches?(plan)).to(be(false))
        end
      end

      describe '#failure_message' do
        it 'includes the expected output change definition' do
          plan = Support::Builders
                   .plan_builder
                   .with_output_creation('other_output_1')
                   .with_output_update('other_output_2')
                   .build

          matcher = described_class.new(
            name: 'some_output',
            create?: true
          )
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(
              include('expected: a plan including at least one ' \
                      "output change matching definition:\n" \
                      "            name = \"some_output\"\n" \
                      "            create? = true\n")
            )
        end

        it 'indicates there are no output changes when none are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_no_output_changes
                   .build

          matcher = described_class.new(
            name: 'some_output',
            create?: true
          )
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including no output changes'))
        end

        it 'indicates there are no matching output changes when some ' \
           'are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_output_creation('other_output_1')
                   .with_output_update('other_output_2')
                   .build

          matcher = described_class.new(
            name: 'some_output',
            create?: true
          )
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including no matching output changes'))
        end

        it 'includes details of the available output changes when some ' \
           'are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_output_creation('other_output_1')
                   .with_output_update('other_output_2')
                   .build

          matcher = described_class.new(
            name: 'some_output',
            create?: true
          )
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(
              include(
                "available output changes are:\n" \
                "            - other_output_1 (create)\n" \
                '            - other_output_2 (update)'
              )
            )
        end
      end
    end
  end

  describe 'values' do
    describe '#with_value' do
      describe '#matches?' do
        it 'returns true when the plan contains an output change with after ' \
           'value equal to the provided scalar value' do
          plan = Support::Builders
                   .plan_builder
                   .with_output_change(
                     'some_output',
                     after: 'some-value'
                   )
                   .build

          matcher = described_class
                      .new(name: 'some_output')
                      .with_value('some-value')

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'returns true when the plan contains an output change with after ' \
           'value equal to the provided list value' do
          plan = Support::Builders
                   .plan_builder
                   .with_output_change(
                     'some_output',
                     after: %w[value1 value2 value3]
                   )
                   .build

          matcher = described_class
                      .new(name: 'some_output')
                      .with_value(%w[value1 value2 value3])

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'returns true when the plan contains an output change with after ' \
           'value equal to the provided map value' do
          plan = Support::Builders
                   .plan_builder
                   .with_output_change(
                     'some_output',
                     after: {
                       first: 1,
                       second: 2
                     }
                   )
                   .build

          matcher = described_class
                      .new(name: 'some_output')
                      .with_value(
                        {
                          first: 1,
                          second: 2
                        }
                      )

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'returns true when the plan contains an output change with after ' \
           'value equal to the provided complex nested value' do
          plan = Support::Builders
                   .plan_builder
                   .with_output_change(
                     'some_output',
                     after: {
                       first: [
                         { second: 'two' },
                         { third: 'three' }
                       ],
                       fourth: '4th'
                     }
                   )
                   .build

          matcher = described_class
                      .new(name: 'some_output')
                      .with_value(
                        {
                          first: [
                            { second: 'two' },
                            { third: 'three' }
                          ],
                          fourth: '4th'
                        }
                      )

          expect(matcher.matches?(plan)).to(be(true))
        end

        it 'returns false when the plan does not contain an output change ' \
           'with after value equal to the provided scalar value' do
          plan = Support::Builders
                   .plan_builder
                   .with_output_change(
                     'some_output',
                     after: 'other-value'
                   )
                   .build

          matcher = described_class
                      .new(name: 'some_output')
                      .with_value('some-value')

          expect(matcher.matches?(plan)).to(be(false))
        end

        it 'returns false when the plan does not contain an output change ' \
           'with after value equal to the provided list value' do
          plan = Support::Builders
                   .plan_builder
                   .with_output_change(
                     'some_output',
                     after: %w[value1 value2]
                   )
                   .build

          matcher = described_class
                      .new(name: 'some_output')
                      .with_value(%w[value1 value2 value3])

          expect(matcher.matches?(plan)).to(be(false))
        end

        it 'returns false when the plan does not contain an output change ' \
           'with after value equal to the provided map value' do
          plan = Support::Builders
                   .plan_builder
                   .with_output_change(
                     'some_output',
                     after: {
                       first: 1,
                       second: 2
                     }
                   )
                   .build

          matcher = described_class
                      .new(name: 'some_output')
                      .with_value(
                        {
                          second: 2,
                          third: 3
                        }
                      )

          expect(matcher.matches?(plan)).to(be(false))
        end

        it 'returns false when the plan does not contain an output change ' \
           'with after value equal to the provided complex nested value' do
          plan = Support::Builders
                   .plan_builder
                   .with_output_change(
                     'some_output',
                     after: {
                       first: [
                         { second: 'two' },
                         { third: 'three' }
                       ],
                       fourth: '4th'
                     }
                   )
                   .build

          matcher = described_class
                      .new(name: 'some_output')
                      .with_value(
                        {
                          first: [
                            { second: 'three' },
                            { third: 'four' }
                          ]
                        }
                      )

          expect(matcher.matches?(plan)).to(be(false))
        end
      end

      describe '#failure_message' do
        it 'includes the expected value' do
          plan = Support::Builders
                   .plan_builder
                   .with_output_creation(
                     'other_output_1',
                     after: 'other-value-1'
                   )
                   .with_output_update(
                     'other_output_2',
                     after: 'other-value-2'
                   )
                   .build

          matcher = described_class
                      .new(name: 'some_output')
                      .with_value('some-value')
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(
              include('with value after the output change is applied of:' \
                      "\n            value = \"some-value\"")
            )
        end

        it 'indicates there are no output changes when none are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_no_output_changes
                   .build

          matcher = described_class
                      .new(name: 'some_output')
                      .with_value('some-value')
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including no output changes'))
        end

        it 'indicates there are no matching output changes when some ' \
           'are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_output_creation(
                     'some_output',
                     after: {
                       some_key: 'other-value'
                     }
                   )
                   .build

          matcher = described_class
                      .new(name: 'some_output')
                      .with_value(some_key: 'some-value')
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(include('got: a plan including no matching output changes'))
        end

        it 'includes details of the relevant output changes when some ' \
           'matching the definition are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_output_creation(
                     'some_output',
                     after: {
                       some_key: 'other-value-1'
                     }
                   )
                   .build

          matcher = described_class
                      .new(name: 'some_output')
                      .with_value(some_key: 'some-value')
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(
              include(
                "relevant output changes are:\n" \
                "            - some_output (create)\n" \
                "                value = {\n" \
                "                  some_key = \"other-value-1\"\n" \
                '                }'
              )
            )
        end

        it 'includes details of the available output changes when some ' \
           'are present' do
          plan = Support::Builders
                   .plan_builder
                   .with_output_creation('other_output_1')
                   .with_output_update('other_output_2')
                   .build

          matcher = described_class
                      .new(name: 'some_output')
                      .with_value('some-value')
          matcher.matches?(plan)

          expect(matcher.failure_message)
            .to(
              include(
                "available output changes are:\n" \
                "            - other_output_1 (create)\n" \
                '            - other_output_2 (update)'
              )
            )
        end
      end
    end
  end
end
# rubocop:enable Layout/LineContinuationLeadingSpace
# rubocop:enable RSpec/NestedGroups
