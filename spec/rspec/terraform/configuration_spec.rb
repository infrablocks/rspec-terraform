# frozen_string_literal: true

require 'spec_helper'

describe RSpec::Terraform::Configuration do
  describe '#identity_provider' do
    it 'constructs an identity configuration provider' do
      provider =
        instance_double(RSpec::Terraform::Configuration::Providers::Identity)

      allow(RSpec::Terraform::Configuration::Providers::Identity)
        .to(receive(:new).with(no_args).and_return(provider))

      result = described_class.identity_provider

      expect(result).to(eq(provider))
    end
  end

  describe '#in_memory_provider' do
    it 'constructs an in-memory configuration provider passing the ' \
       'supplied options' do
      provider =
        instance_double(RSpec::Terraform::Configuration::Providers::InMemory)
      opts = { some: 'options' }

      allow(RSpec::Terraform::Configuration::Providers::InMemory)
        .to(receive(:new).with(opts).and_return(provider))

      result = described_class.in_memory_provider(opts)

      expect(result).to(eq(provider))
    end

    it 'constructs an in-memory configuration provider passing an empty map ' \
       'when no options supplied' do
      provider =
        instance_double(RSpec::Terraform::Configuration::Providers::InMemory)

      allow(RSpec::Terraform::Configuration::Providers::InMemory)
        .to(receive(:new).with({}).and_return(provider))

      result = described_class.in_memory_provider

      expect(result).to(eq(provider))
    end
  end

  describe '#confidante_provider' do
    it 'constructs a confidante configuration provider passing the ' \
       'supplied options' do
      provider =
        instance_double(RSpec::Terraform::Configuration::Providers::Confidante)
      opts = { some: 'options' }

      allow(RSpec::Terraform::Configuration::Providers::Confidante)
        .to(receive(:new).with(opts).and_return(provider))

      result = described_class.confidante_provider(opts)

      expect(result).to(eq(provider))
    end

    it 'constructs a confidante configuration provider passing an empty map ' \
       'when no options supplied' do
      provider =
        instance_double(RSpec::Terraform::Configuration::Providers::Confidante)

      allow(RSpec::Terraform::Configuration::Providers::Confidante)
        .to(receive(:new).with({}).and_return(provider))

      result = described_class.confidante_provider

      expect(result).to(eq(provider))
    end
  end

  describe '#seed_provider' do
    it 'constructs a seed configuration provider passing the ' \
       'supplied options' do
      provider =
        instance_double(RSpec::Terraform::Configuration::Providers::Seed)
      opts = { some: 'options' }

      allow(RSpec::Terraform::Configuration::Providers::Seed)
        .to(receive(:new).with(opts).and_return(provider))

      result = described_class.seed_provider(opts)

      expect(result).to(eq(provider))
    end

    it 'constructs a seed configuration provider passing an empty map ' \
       'when no options supplied' do
      provider =
        instance_double(RSpec::Terraform::Configuration::Providers::Seed)

      allow(RSpec::Terraform::Configuration::Providers::Seed)
        .to(receive(:new).with({}).and_return(provider))

      result = described_class.seed_provider

      expect(result).to(eq(provider))
    end
  end

  describe '#chain_provider' do
    it 'constructs a chain configuration provider passing the ' \
       'supplied options' do
      provider =
        instance_double(RSpec::Terraform::Configuration::Providers::Chain)
      opts = { some: 'options' }

      allow(RSpec::Terraform::Configuration::Providers::Chain)
        .to(receive(:new).with(opts).and_return(provider))

      result = described_class.chain_provider(opts)

      expect(result).to(eq(provider))
    end

    it 'constructs a chain configuration provider passing an empty map ' \
       'when no options supplied' do
      provider =
        instance_double(RSpec::Terraform::Configuration::Providers::Chain)

      allow(RSpec::Terraform::Configuration::Providers::Chain)
        .to(receive(:new).with({}).and_return(provider))

      result = described_class.chain_provider

      expect(result).to(eq(provider))
    end
  end
end
