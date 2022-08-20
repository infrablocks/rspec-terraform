# frozen_string_literal: true

require 'spec_helper'

describe RSpec::Terraform::Helpers::Apply do
  # rubocop:disable RSpec/MultipleExpectations
  it 'invokes init before apply' do
    init = stub_ruby_terraform_init
    apply = stub_ruby_terraform_apply

    helper = described_class.new(required_parameters)
    helper.execute

    expect(init).to(have_received(:execute).ordered)
    expect(apply).to(have_received(:execute).ordered)
  end
  # rubocop:enable RSpec/MultipleExpectations

  describe 'by default' do
    it 'throws if no configuration_directory is provided' do
      stub_ruby_terraform_init
      stub_ruby_terraform_apply

      helper = described_class.new

      expect { helper.execute }.to(raise_error(StandardError))
    end

    describe 'for init' do
      it 'instructs Terraform not to request interactive input' do
        init = stub_ruby_terraform_init
        stub_ruby_terraform_apply

        helper = described_class.new(required_parameters)
        helper.execute

        expect(init)
          .to(have_received(:execute)
                .with(hash_including(input: false)))
      end

      it 'inits the specified Terraform configuration in place' do
        init = stub_ruby_terraform_init
        stub_ruby_terraform_apply

        helper = described_class.new(
          configuration_directory: 'path/to/terraform/configuration'
        )
        helper.execute

        expect(init)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'path/to/terraform/configuration'
                      )))
      end

      it 'uses a Terraform binary of "terraform"' do
        init = stub_ruby_terraform_init(binary: 'terraform')
        stub_ruby_terraform_apply

        helper = described_class.new(required_parameters)
        helper.execute

        expect(init)
          .to(have_received(:execute))
      end
    end

    describe 'for apply' do
      it 'instructs Terraform not to request interactive input' do
        stub_ruby_terraform_init
        apply = stub_ruby_terraform_apply

        helper = described_class.new(required_parameters)
        helper.execute

        expect(apply)
          .to(have_received(:execute)
                .with(hash_including(input: false)))
      end

      it 'instructs Terraform to auto approve the plan' do
        stub_ruby_terraform_init
        apply = stub_ruby_terraform_apply

        helper = described_class.new(required_parameters)
        helper.execute

        expect(apply)
          .to(have_received(:execute)
                .with(hash_including(auto_approve: true)))
      end

      it 'does not specify a state file' do
        stub_ruby_terraform_init
        apply = stub_ruby_terraform_apply

        helper = described_class.new(required_parameters)
        helper.execute

        expect(apply)
          .not_to(have_received(:execute)
                    .with(hash_including(:state_file)))
      end

      it 'applies the specified Terraform configuration in place' do
        stub_ruby_terraform_init
        apply = stub_ruby_terraform_apply

        helper = described_class.new(
          configuration_directory: 'path/to/terraform/configuration'
        )
        helper.execute

        expect(apply)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'path/to/terraform/configuration'
                      )))
      end

      it 'uses a Terraform binary of "terraform"' do
        stub_ruby_terraform_init
        apply = stub_ruby_terraform_apply(binary: 'terraform')

        helper = described_class.new(required_parameters)
        helper.execute

        expect(apply)
          .to(have_received(:execute))
      end
    end
  end

  context 'when Terraform binary overridden' do
    def terraform_binary
      'path/to/binary'
    end

    around do |example|
      previous = RSpec.configuration.terraform_binary
      RSpec.configuration.terraform_binary = terraform_binary
      example.run
      RSpec.configuration.terraform_binary = previous
    end

    it 'inits using the specified binary' do
      init = stub_ruby_terraform_init(binary: terraform_binary)
      stub_ruby_terraform_apply

      helper = described_class.new(required_parameters)
      helper.execute

      expect(init)
        .to(have_received(:execute))
    end

    it 'applies using the specified binary' do
      stub_ruby_terraform_init
      apply = stub_ruby_terraform_apply(binary: terraform_binary)

      helper = described_class.new(required_parameters)
      helper.execute

      expect(apply)
        .to(have_received(:execute))
    end
  end

  context 'when configuration overrides provided' do
    describe 'for init' do
      it 'uses the specified Terraform configuration' do
        init = stub_ruby_terraform_init
        stub_ruby_terraform_apply

        helper = described_class.new(
          configuration_directory: 'path/to/terraform/configuration'
        )
        helper.execute

        expect(init)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'path/to/terraform/configuration'
                      )))
      end
    end

    describe 'for apply' do
      it 'uses the specified Terraform configuration' do
        stub_ruby_terraform_init
        apply = stub_ruby_terraform_apply

        helper = described_class.new(
          configuration_directory: 'path/to/terraform/configuration'
        )
        helper.execute

        expect(apply)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'path/to/terraform/configuration'
                      )))
      end

      it 'uses the specified state file' do
        stub_ruby_terraform_init
        apply = stub_ruby_terraform_apply

        helper = described_class.new(
          required_parameters.merge(
            state_file: 'path/to/terraform/state'
          )
        )
        helper.execute

        expect(apply)
          .to(have_received(:execute)
                .with(hash_including(
                        state: 'path/to/terraform/state'
                      )))
      end

      it 'uses the specified vars' do
        stub_ruby_terraform_init
        apply = stub_ruby_terraform_apply

        helper = described_class.new(
          required_parameters.merge(
            vars: {
              first: 1,
              second: 2
            }
          )
        )
        helper.execute

        expect(apply)
          .to(have_received(:execute)
                .with(hash_including(
                        vars: {
                          first: 1,
                          second: 2
                        }
                      )))
      end
    end
  end

  context 'when configuration provider supplied' do
    describe 'for init' do
      it 'uses the Terraform configuration returned by the provider' do
        init = stub_ruby_terraform_init
        stub_ruby_terraform_apply

        configuration_provider =
          RSpec::Terraform::Configuration.in_memory_provider(
            configuration_directory: 'provided/terraform/configuration'
          )

        helper = described_class.new(
          {}, configuration_provider
        )
        helper.execute

        expect(init)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'provided/terraform/configuration'
                      )))
      end

      it 'passes configuration overrides to the provider when present' do
        init = stub_ruby_terraform_init
        stub_ruby_terraform_apply

        in_memory_configuration = {
          configuration_directory: 'provided/terraform/configuration'
        }
        override_configuration = {
          configuration_directory: 'override/terraform/configuration'
        }
        configuration_provider =
          RSpec::Terraform::Configuration.in_memory_provider(
            in_memory_configuration
          )

        helper = described_class.new(
          override_configuration, configuration_provider
        )
        helper.execute

        expect(init)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'override/terraform/configuration'
                      )))
      end
    end

    describe 'for apply' do
      it 'uses the Terraform configuration returned by the provider' do
        stub_ruby_terraform_init
        apply = stub_ruby_terraform_apply

        configuration_provider =
          RSpec::Terraform::Configuration.in_memory_provider(
            configuration_directory: 'provided/terraform/configuration'
          )

        helper = described_class.new(
          {}, configuration_provider
        )
        helper.execute

        expect(apply)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'provided/terraform/configuration'
                      )))
      end

      it 'uses the state file returned by the provider' do
        stub_ruby_terraform_init
        apply = stub_ruby_terraform_apply

        configuration_provider =
          RSpec::Terraform::Configuration.in_memory_provider(
            required_parameters.merge(
              state_file: 'provided/terraform/state'
            )
          )

        helper = described_class.new(
          {}, configuration_provider
        )
        helper.execute

        expect(apply)
          .to(have_received(:execute)
                .with(hash_including(
                        state: 'provided/terraform/state'
                      )))
      end

      it 'uses the vars returned by the provider' do
        stub_ruby_terraform_init
        apply = stub_ruby_terraform_apply

        configuration_provider =
          RSpec::Terraform::Configuration.in_memory_provider(
            required_parameters.merge(
              vars: {
                first: 1,
                second: 2
              }
            )
          )

        helper = described_class.new(
          {}, configuration_provider
        )
        helper.execute

        expect(apply)
          .to(have_received(:execute)
                .with(hash_including(
                        vars: {
                          first: 1,
                          second: 2
                        }
                      )))
      end

      it 'passes configuration overrides to the provider when present' do
        stub_ruby_terraform_init
        apply = stub_ruby_terraform_apply

        in_memory_configuration = {
          configuration_directory: 'provided/terraform/configuration',
          state_file: 'provided/state/file',
          vars: {
            first: 1,
            second: 2
          }
        }
        override_configuration = {
          configuration_directory: 'override/terraform/configuration',
          state_file: 'override/state/file',
          vars: {
            second: 'two',
            third: 'three'
          }
        }
        configuration_provider =
          RSpec::Terraform::Configuration.in_memory_provider(
            in_memory_configuration
          )

        helper = described_class.new(
          override_configuration, configuration_provider
        )
        helper.execute

        expect(apply)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'override/terraform/configuration',
                        state: 'override/state/file',
                        vars: {
                          first: 1,
                          second: 'two',
                          third: 'three'
                        }
                      )))
      end
    end
  end

  context 'when vars block passed' do
    it 'passes the vars configured in the block to apply' do
      stub_ruby_terraform_init
      apply = stub_ruby_terraform_apply

      helper = described_class.new(required_parameters)
      helper.execute do |vars|
        vars.first = 1
        vars.second = 2
      end

      expect(apply)
        .to(have_received(:execute)
              .with(hash_including(
                      vars: {
                        first: 1,
                        second: 2
                      }
                    )))
    end

    it 'exposes existing vars within block' do
      stub_ruby_terraform_init
      apply = stub_ruby_terraform_apply

      helper = described_class.new(
        required_parameters.merge(
          vars: {
            first: 1,
            second: 2
          }
        )
      )
      helper.execute do |vars|
        vars.third = vars.first + vars.second
      end

      expect(apply)
        .to(have_received(:execute)
              .with(hash_including(
                      vars: {
                        first: 1,
                        second: 2,
                        third: 3
                      }
                    )))
    end

    it 'gives precedence to the vars in the block over those in overrides' do
      stub_ruby_terraform_init
      apply = stub_ruby_terraform_apply

      helper = described_class.new(
        required_parameters.merge(
          vars: {
            first: 1,
            second: 2
          }
        )
      )
      helper.execute do |vars|
        vars.second = 'two'
        vars.third = 'three'
      end

      expect(apply)
        .to(have_received(:execute)
              .with(hash_including(
                      vars: {
                        first: 1,
                        second: 'two',
                        third: 'three'
                      }
                    )))
    end

    it 'gives precedence to the vars from a provider over those in overrides' do
      stub_ruby_terraform_init
      apply = stub_ruby_terraform_apply

      configuration_provider =
        RSpec::Terraform::Configuration.in_memory_provider(
          vars: {
            first: 1,
            second: 2
          }
        )

      helper = described_class.new(
        required_parameters,
        configuration_provider
      )
      helper.execute do |vars|
        vars.second = 'two'
        vars.third = 'three'
      end

      expect(apply)
        .to(have_received(:execute)
              .with(hash_including(
                      vars: {
                        first: 1,
                        second: 'two',
                        third: 'three'
                      }
                    )))
    end
  end

  def required_parameters
    { configuration_directory: 'path/to/configuration' }
  end

  def stub_ruby_terraform_init(opts = nil)
    init = instance_double(RubyTerraform::Commands::Init)
    allow(init).to(receive(:execute))

    expectation = receive(:new)
    expectation = expectation.with(opts) if opts
    expectation = expectation.and_return(init)
    allow(RubyTerraform::Commands::Init).to(expectation)

    init
  end

  def stub_ruby_terraform_apply(opts = nil)
    apply = instance_double(RubyTerraform::Commands::Apply)
    allow(apply).to(receive(:execute))

    expectation = receive(:new)
    expectation = expectation.with(opts) if opts
    expectation = expectation.and_return(apply)
    allow(RubyTerraform::Commands::Apply).to(expectation)

    apply
  end
end
