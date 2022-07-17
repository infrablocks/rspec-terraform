# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/NestedGroups
describe RSpec::Terraform::Matchers::IncludeResourceChange do
  describe 'definitions' do
    describe 'without definition' do
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

    describe 'with type defined' do
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

      it 'mismatches when plan does not include a resource change with type' do
        plan = Support::Builders
                 .plan_builder
                 .with_resource_creation(type: 'other_resource_type1')
                 .with_resource_creation(type: 'other_resource_type2')
                 .build

        matcher = described_class.new(type: 'some_resource_type')

        expect(matcher.matches?(plan)).to(be(false))
      end
    end

    describe 'with type and name defined' do
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

    describe 'with type, name and index defined' do
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
  end

  describe 'cardinality' do
    describe '#once' do
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

      it 'mismatches when multiple resource change meet definition' do
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

    describe '#twice' do
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

    describe '#thrice' do
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

    describe '#exactly' do
      it 'matches when specified number of resource changes meet definition' do
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

    describe '#at_most' do
      it 'matches when specified number of resource changes meet definition' do
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

    describe '#at_least' do
      it 'matches when specified number of resource changes meet definition' do
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
  end

  describe 'attributes' do
    describe '#with_attribute_value' do
      context 'when attribute selector is a symbol' do
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

      context 'when attribute selector is a path' do
        it 'matches when resource change has after attribute at simple path ' \
           'with matching value' do
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

        it 'mismatches when resource change has after attribute at simple ' \
           'path with mismatching value' do
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

      context 'when attribute value is a scalar' do
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

        it 'mismatches when resource change has after attribute at path with ' \
           'different scalar value' do
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

      context 'when attribute value is a list' do
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

        it 'mismatches when resource change has after attribute at path with ' \
           'different list value' do
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

      context 'when attribute value is a map' do
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

        it 'mismatches when resource change has after attribute at path with ' \
           'different map value' do
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

      context 'when attribute value is a complex nested value' do
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

        it 'mismatches when resource change has after attribute at path with ' \
           'different complex nested value' do
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

      context 'when attribute value is a matcher' do
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
                      .with_attribute_value(:some_attribute, including('some'))

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
                      .with_attribute_value(:some_attribute, including('other'))

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
    end
  end
end
# rubocop:enable RSpec/NestedGroups
