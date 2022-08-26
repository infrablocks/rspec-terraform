# frozen_string_literal: true

require 'spec_helper'

describe RSpec::Terraform::Helpers::Var do
  context 'when configuration overrides provided' do
    it 'looks up the var by name in the vars in overrides' do
      overrides = {
        vars: {
          first: 1,
          second: 2
        },
        name: 'first'
      }
      helper = described_class.new
      result = helper.execute(overrides)

      expect(result).to(eq(1))
    end

    it 'returns nil when no var in vars in overrides with name' do
      overrides = {
        vars: {
          first: 1,
          second: 2
        },
        name: 'third'
      }
      helper = described_class.new
      result = helper.execute(overrides)

      expect(result).to(be_nil)
    end
  end

  context 'when configuration provider supplied' do
    it 'looks up the var by name in the vars returned by provider' do
      configuration_provider =
        RSpec::Terraform::Configuration.in_memory_provider(
          vars: {
            first: 1,
            second: 2
          },
          name: 'first'
        )

      helper = described_class.new(
        configuration_provider: configuration_provider
      )
      result = helper.execute

      expect(result).to(eq(1))
    end

    it 'returns nil when no var with name in vars returned by provider' do
      configuration_provider =
        RSpec::Terraform::Configuration.in_memory_provider(
          vars: {
            first: 1,
            second: 2
          },
          name: 'third'
        )

      helper = described_class.new(
        configuration_provider: configuration_provider
      )
      result = helper.execute

      expect(result).to(be_nil)
    end

    it 'passes overrides to provider when present' do
      in_memory_configuration = {
        vars: {
          first: 1,
          second: 2
        },
        name: 'first'
      }
      override_configuration = {
        vars: {
          second: 'two',
          third: 'three'
        },
        name: 'second'
      }
      configuration_provider =
        RSpec::Terraform::Configuration.in_memory_provider(
          in_memory_configuration
        )

      helper = described_class.new(
        configuration_provider: configuration_provider
      )
      result = helper.execute(override_configuration)

      expect(result).to(eq('two'))
    end
  end

  context 'when vars block passed' do
    it 'looks up the var by name in the vars configured in the block' do
      helper = described_class.new
      result = helper.execute(name: 'second') do |vars|
        vars.first = 1
        vars.second = 2
      end

      expect(result).to(eq(2))
    end

    it 'exposes existing vars within block' do
      helper = described_class.new
      result = helper.execute(
        vars: {
          first: 1,
          second: 2
        },
        name: 'third'
      ) do |vars|
        vars.third = vars.first + vars.second
      end

      expect(result).to(eq(3))
    end

    it 'gives precedence to the vars in the block over those in overrides' do
      helper = described_class.new
      result = helper.execute(
        vars: {
          first: 1,
          second: 2
        },
        name: 'second'
      ) do |vars|
        vars.second = 'two'
        vars.third = 'three'
      end

      expect(result).to(eq('two'))
    end

    it 'gives precedence to the vars from a provider over those in overrides' do
      configuration_provider =
        RSpec::Terraform::Configuration.in_memory_provider(
          vars: {
            first: 1,
            second: 2
          },
          name: 'second'
        )

      helper = described_class.new(
        configuration_provider: configuration_provider
      )
      result = helper.execute do |vars|
        vars.second = 'two'
        vars.third = 'three'
      end

      expect(result).to(eq('two'))
    end
  end
end
