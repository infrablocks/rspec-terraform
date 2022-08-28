# frozen_string_literal: true

require 'spec_helper'
require 'confidante'

describe RSpec::Terraform::Configuration::Providers::Chain do
  describe '#resolve' do
    it 'calls supplied providers in order threading through the parameters' do
      provider1 =
        instance_double(RSpec::Terraform::Configuration::Providers::Base)
      provider2 =
        instance_double(RSpec::Terraform::Configuration::Providers::Base)

      overrides = { first: 1, second: 2 }
      provider1_result = { first: 1, second: 'two', third: 'three' }
      provider2_result =
        { first: 1, second: 'two', third: 3, fourth: { a: 'b', c: 'd' } }

      allow(provider1)
        .to(receive(:resolve).with(overrides).and_return(provider1_result))
      allow(provider2)
        .to(receive(:resolve).with(provider1_result)
                             .and_return(provider2_result))

      provider = described_class.new(providers: [provider1, provider2])
      result = provider.resolve(overrides)

      expect(result).to(eq(provider2_result))
    end

    it 'uses an empty map for overrides when none provided' do
      provider1 =
        instance_double(RSpec::Terraform::Configuration::Providers::Base)
      provider2 =
        instance_double(RSpec::Terraform::Configuration::Providers::Base)

      result1 = { first: 1, second: 'two' }
      result2 = { first: 1, second: 'two', third: 3 }

      allow(provider1).to(receive(:resolve).with({}).and_return(result1))
      allow(provider2).to(receive(:resolve).with(result1).and_return(result2))

      provider = described_class.new(providers: [provider1, provider2])
      result = provider.resolve

      expect(result).to(eq(result2))
    end

    it 'returns the result from the single provider when only one supplied' do
      provider1 =
        instance_double(RSpec::Terraform::Configuration::Providers::Base)

      result1 = { first: 1, second: 'two' }

      allow(provider1).to(receive(:resolve).with({}).and_return(result1))

      provider = described_class.new(providers: [provider1])
      result = provider.resolve

      expect(result).to(eq(result1))
    end

    it 'returns an empty map when empty list of providers supplied and ' \
       'no overrides supplied' do
      provider = described_class.new(providers: [])
      result = provider.resolve

      expect(result).to(eq({}))
    end

    it 'returns an empty map when no providers supplied and ' \
       'no overrides supplied' do
      provider = described_class.new
      result = provider.resolve

      expect(result).to(eq({}))
    end

    it 'returns overrides when empty list of providers supplied and ' \
       'overrides supplied' do
      overrides = {
        first: 1,
        second: 2
      }

      provider = described_class.new(providers: [])
      result = provider.resolve(overrides)

      expect(result).to(eq(overrides))
    end

    it 'returns overrides when no providers supplied and ' \
       'overrides supplied' do
      overrides = {
        first: 1,
        second: 2
      }

      provider = described_class.new
      result = provider.resolve(overrides)

      expect(result).to(eq(overrides))
    end
  end

  describe '#reset' do
    # rubocop:disable RSpec/MultipleExpectations
    it 'resets each of the supplied providers' do
      provider1 =
        instance_double(RSpec::Terraform::Configuration::Providers::Base)
      provider2 =
        instance_double(RSpec::Terraform::Configuration::Providers::Base)

      allow(provider1).to(receive(:reset))
      allow(provider2).to(receive(:reset))

      provider = described_class.new(providers: [provider1, provider2])
      provider.reset

      expect(provider1).to(have_received(:reset).ordered)
      expect(provider2).to(have_received(:reset).ordered)
    end
    # rubocop:enable RSpec/MultipleExpectations

    it 'resets single supplied provider when only one' do
      provider1 =
        instance_double(RSpec::Terraform::Configuration::Providers::Base)

      allow(provider1).to(receive(:reset))

      provider = described_class.new(providers: [provider1])
      provider.reset

      expect(provider1).to(have_received(:reset))
    end

    it 'does not raise error when empty list of providers supplied' do
      provider = described_class.new(providers: [])

      expect { provider.reset }.not_to(raise_error)
    end

    it 'does not raise error when no providers supplied' do
      provider = described_class.new

      expect { provider.reset }.not_to(raise_error)
    end
  end
end
