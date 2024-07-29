# frozen_string_literal: true

require 'spec_helper'
require 'confidante'
require 'securerandom'

describe RSpec::Terraform::Configuration::Providers::Seed do
  describe '#resolve' do
    context 'when no overrides provided' do
      it 'returns a seed' do
        provider = described_class.new
        result = provider.resolve

        expect(result).to(include(:seed))
      end

      it 'returns the same seed on every invocation when not reset' do
        provider = described_class.new
        result = 10.times.collect { |_| provider.resolve }

        expect(result.uniq.length).to(eq(1))
      end

      it 'returns a random alphanumeric string of length 10 by default' do
        provider = described_class.new
        result = provider.resolve

        expect(result[:seed]).to(match(/^[a-zA-Z0-9]{10}$/))
      end

      it 'uses the specified generator when provided' do
        provider = described_class.new(
          generator: -> { SecureRandom.hex[0, 8] }
        )
        result = provider.resolve

        expect(result[:seed]).to(match(/^[0-9a-f]{8}$/))
      end
    end

    context 'when overrides provided' do
      it 'shallow merges overrides into resulting parameters by default' do
        overrides = {
          first_parameter: 'first',
          second_parameter: 'second'
        }
        provider = described_class.new
        result = provider.resolve(overrides)

        expect(result)
          .to(eq(
                {
                  first_parameter: 'first',
                  second_parameter: 'second',
                  seed: result[:seed]
                }
              ))
      end

      it 'gives precedence to overrides by default' do
        overrides = {
          seed: '12345'
        }
        provider = described_class.new
        result = provider.resolve(overrides)

        expect(result[:seed])
          .to(eq('12345'))
      end

      it 'uses the specified merger when provided' do
        overrides = {
          first: 1,
          second: 2,
          third: 3
        }

        merger = Object.new
        def merger.merge(left, right)
          left.merge(right.slice(:second))
        end

        provider = described_class.new(merger:)
        result = provider.resolve(overrides)

        expect(result)
          .to(eq({ second: 2, seed: result[:seed] }))
      end
    end
  end

  describe '#reset' do
    it 'resets the seed value such that subsequent resolves return ' \
       'a different seed' do
      provider = described_class.new
      result = 10.times.collect do |_|
        seed = provider.resolve
        provider.reset
        seed
      end

      expect(result.uniq.length).to(eq(10))
    end
  end
end
