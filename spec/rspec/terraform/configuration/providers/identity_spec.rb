# frozen_string_literal: true

require 'spec_helper'

describe RSpec::Terraform::Configuration::Providers::Identity do
  describe '#resolve' do
    context 'when no overrides provided' do
      it 'returns an empty map' do
        provider = described_class.new
        result = provider.resolve

        expect(result).to(eq({}))
      end
    end

    context 'when overrides provided' do
      it 'returns the overrides unchanged' do
        overrides = {
          first_parameter: 1,
          second_parameter: 2
        }
        provider = described_class.new
        result = provider.resolve(overrides)

        expect(result).to(eq(overrides))
      end
    end
  end

  describe '#reset' do
    it 'does nothing' do
      provider = described_class.new

      expect { provider.reset }.not_to(raise_error)
    end
  end
end
