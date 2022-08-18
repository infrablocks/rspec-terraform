# frozen_string_literal: true

require 'spec_helper'

describe RSpec::Terraform::Helpers::Apply do
  describe 'by default' do
    it 'instructs Terraform not to request interactive input' do
      stub_ruby_terraform

      helper = described_class.new
      helper.execute

      expect(RubyTerraform)
        .to(have_received(:apply)
              .with(hash_including(input: false)))
    end

    it 'instructs Terraform to auto approve the plan' do
      stub_ruby_terraform

      helper = described_class.new
      helper.execute

      expect(RubyTerraform)
        .to(have_received(:apply)
              .with(hash_including(auto_approve: true)))
    end
  end

  context 'when configuration overrides provided' do
    it 'applies the specified Terraform configuration' do
      stub_ruby_terraform

      helper = described_class.new(
        configuration_directory: 'path/to/terraform/configuration'
      )
      helper.execute

      expect(RubyTerraform)
        .to(have_received(:apply)
              .with(hash_including(
                      chdir: 'path/to/terraform/configuration'
                    )))
    end

    it 'uses the specified state file' do
      stub_ruby_terraform

      helper = described_class.new(
        state_file: 'path/to/terraform/state'
      )
      helper.execute

      expect(RubyTerraform)
        .to(have_received(:apply)
              .with(hash_including(
                      state: 'path/to/terraform/state'
                    )))
    end

    it 'uses the specified vars' do
      stub_ruby_terraform

      helper = described_class.new(
        vars: {
          first: 1,
          second: 2
        }
      )
      helper.execute

      expect(RubyTerraform)
        .to(have_received(:apply)
              .with(hash_including(
                      vars: {
                        first: 1,
                        second: 2
                      }
                    )))
    end
  end

  context 'when configuration provider supplied' do
    it 'uses the parameters returns by the configuration provider' do
      stub_ruby_terraform

      configuration_provider =
        RSpec::Terraform::Configuration.in_memory_provider(
          configuration_directory: 'provided/terraform/configuration'
        )

      helper = described_class.new(
        {}, configuration_provider
      )
      helper.execute

      expect(RubyTerraform)
        .to(have_received(:apply)
              .with(hash_including(
                      chdir: 'provided/terraform/configuration'
                    )))
    end
  end

  def stub_ruby_terraform
    allow(RubyTerraform).to(receive(:apply))
  end

  def stub_rspec_configuration(settings)
    configuration = RSpec.configuration
    settings.each do |setting, value|
      allow(configuration)
        .to(receive(setting)
              .and_return(value))
    end
  end
end
