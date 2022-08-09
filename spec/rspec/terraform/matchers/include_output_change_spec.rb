# frozen_string_literal: true

require 'spec_helper'

describe RSpec::Terraform::Matchers::IncludeOutputChange do
  describe 'definitions' do
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
      end
    end
  end
end
