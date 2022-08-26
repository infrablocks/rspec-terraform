# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'

describe RSpec::Terraform::Helpers::Apply do
  before do
    stub_rm_rf
    stub_mkdir_p
  end

  # rubocop:disable RSpec/MultipleExpectations
  it 'invokes init before apply' do
    init = stub_ruby_terraform_init
    apply = stub_ruby_terraform_apply

    helper = described_class.new
    helper.execute(required_parameters)

    expect(init).to(have_received(:execute).ordered)
    expect(apply).to(have_received(:execute).ordered)
  end
  # rubocop:enable RSpec/MultipleExpectations

  describe 'by default' do
    it 'throws if no configuration_directory is provided' do
      stub_ruby_terraform_init
      stub_ruby_terraform_apply

      helper = described_class.new

      expect { helper.execute }
        .to(raise_error(
              StandardError,
              'Required parameter: `:configuration_directory` missing.'
            ))
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'does not delete and recreate the configuration directory ' \
       'before invoking Terraform' do
      stub_ruby_terraform_init
      stub_ruby_terraform_apply

      helper = described_class.new
      helper.execute(required_parameters)

      expect(FileUtils).not_to(have_received(:rm_rf))
      expect(FileUtils).not_to(have_received(:mkdir_p))
    end
    # rubocop:enable RSpec/MultipleExpectations

    describe 'for init' do
      it 'instructs Terraform not to request interactive input' do
        init = stub_ruby_terraform_init
        stub_ruby_terraform_apply

        helper = described_class.new
        helper.execute(required_parameters)

        expect(init)
          .to(have_received(:execute)
                .with(hash_including(input: false)))
      end

      it 'inits the specified Terraform configuration in place' do
        init = stub_ruby_terraform_init
        stub_ruby_terraform_apply

        helper = described_class.new
        helper.execute(
          configuration_directory: 'path/to/terraform/configuration'
        )

        expect(init)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'path/to/terraform/configuration'
                      )))
      end

      it 'does not include the from_module parameter' do
        init = stub_ruby_terraform_init
        stub_ruby_terraform_apply

        helper = described_class.new
        helper.execute(
          configuration_directory: 'path/to/terraform/configuration'
        )

        expect(init)
          .not_to(have_received(:execute)
                    .with(hash_including(:from_module)))
      end

      it 'uses a Terraform binary of "terraform"' do
        init = stub_ruby_terraform_init(binary: 'terraform')
        stub_ruby_terraform_apply

        helper = described_class.new
        helper.execute(required_parameters)

        expect(init)
          .to(have_received(:execute))
      end
    end

    describe 'for apply' do
      it 'instructs Terraform not to request interactive input' do
        stub_ruby_terraform_init
        apply = stub_ruby_terraform_apply

        helper = described_class.new
        helper.execute(required_parameters)

        expect(apply)
          .to(have_received(:execute)
                .with(hash_including(input: false)))
      end

      it 'instructs Terraform to auto approve the plan' do
        stub_ruby_terraform_init
        apply = stub_ruby_terraform_apply

        helper = described_class.new
        helper.execute(required_parameters)

        expect(apply)
          .to(have_received(:execute)
                .with(hash_including(auto_approve: true)))
      end

      it 'does not specify a state file' do
        stub_ruby_terraform_init
        apply = stub_ruby_terraform_apply

        helper = described_class.new
        helper.execute(required_parameters)

        expect(apply)
          .not_to(have_received(:execute)
                    .with(hash_including(:state)))
      end

      it 'applies the specified Terraform configuration in place' do
        stub_ruby_terraform_init
        apply = stub_ruby_terraform_apply

        helper = described_class.new
        helper.execute(
          configuration_directory: 'path/to/terraform/configuration'
        )

        expect(apply)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'path/to/terraform/configuration'
                      )))
      end

      it 'uses a Terraform binary of "terraform"' do
        stub_ruby_terraform_init
        apply = stub_ruby_terraform_apply(binary: 'terraform')

        helper = described_class.new
        helper.execute(required_parameters)

        expect(apply)
          .to(have_received(:execute))
      end
    end
  end

  context 'when Terraform execution mode is :in_place' do
    def terraform_execution_mode
      :in_place
    end

    around do |example|
      previous = RSpec.configuration.terraform_execution_mode
      RSpec.configuration.terraform_execution_mode = terraform_execution_mode
      example.run
      RSpec.configuration.terraform_execution_mode = previous
    end

    it 'throws if no configuration_directory is provided' do
      stub_ruby_terraform_init
      stub_ruby_terraform_apply

      helper = described_class.new

      expect { helper.execute }
        .to(raise_error(
              StandardError,
              'Required parameter: `:configuration_directory` missing.'
            ))
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'does not delete and recreate the configuration directory ' \
       'before invoking Terraform' do
      stub_ruby_terraform_init
      stub_ruby_terraform_apply

      helper = described_class.new
      helper.execute(
        required_parameters(execution_mode: :in_place)
      )

      expect(FileUtils).not_to(have_received(:rm_rf))
      expect(FileUtils).not_to(have_received(:mkdir_p))
    end
    # rubocop:enable RSpec/MultipleExpectations

    describe 'for init' do
      it 'inits the specified Terraform configuration in place' do
        init = stub_ruby_terraform_init
        stub_ruby_terraform_apply

        helper = described_class.new
        helper.execute(
          configuration_directory: 'path/to/terraform/configuration'
        )

        expect(init)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'path/to/terraform/configuration'
                      )))
      end

      it 'does not include the from_module parameter' do
        init = stub_ruby_terraform_init
        stub_ruby_terraform_apply

        helper = described_class.new
        helper.execute(
          configuration_directory: 'path/to/terraform/configuration'
        )

        expect(init)
          .not_to(have_received(:execute)
                    .with(hash_including(:from_module)))
      end
    end

    describe 'for apply' do
      it 'applies the specified Terraform configuration in place' do
        stub_ruby_terraform_init
        apply = stub_ruby_terraform_apply

        helper = described_class.new
        helper.execute(
          configuration_directory: 'path/to/terraform/configuration'
        )

        expect(apply)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'path/to/terraform/configuration'
                      )))
      end
    end
  end

  context 'when Terraform execution mode is :isolated' do
    def terraform_execution_mode
      :isolated
    end

    around do |example|
      previous = RSpec.configuration.terraform_execution_mode
      RSpec.configuration.terraform_execution_mode = terraform_execution_mode
      example.run
      RSpec.configuration.terraform_execution_mode = previous
    end

    it 'throws if no configuration_directory is provided' do
      stub_ruby_terraform_init
      stub_ruby_terraform_apply

      helper = described_class.new

      expect do
        helper.execute(
          source_directory: 'path/to/source/configuration'
        )
      end.to(raise_error(
               StandardError,
               'Required parameter: `:configuration_directory` missing.'
             ))
    end

    it 'throws if no source_directory is provided' do
      stub_ruby_terraform_init
      stub_ruby_terraform_apply

      helper = described_class.new

      expect do
        helper.execute(
          configuration_directory: 'path/to/destination/configuration'
        )
      end.to(raise_error(
               StandardError,
               'Required parameter: `:source_directory` missing.'
             ))
    end

    it 'throws if no source_directory or configuration_directory provided' do
      stub_ruby_terraform_init
      stub_ruby_terraform_apply

      helper = described_class.new

      expect { helper.execute }
        .to(raise_error(
              StandardError,
              'Required parameters: `:source_directory` and ' \
              '`:configuration_directory` missing.'
            ))
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'deletes and recreates the configuration directory ' \
       'before invoking Terraform' do
      init = stub_ruby_terraform_init
      apply = stub_ruby_terraform_apply

      helper = described_class.new
      helper.execute(
        required_parameters(execution_mode: :isolated)
          .merge(configuration_directory: 'path/to/destination/configuration')
      )

      expect(FileUtils)
        .to(have_received(:rm_rf)
              .with('path/to/destination/configuration')
              .ordered)
      expect(FileUtils)
        .to(have_received(:mkdir_p)
              .with('path/to/destination/configuration')
              .ordered)
      expect(init).to(have_received(:execute).ordered)
      expect(apply).to(have_received(:execute).ordered)
    end
    # rubocop:enable RSpec/MultipleExpectations

    describe 'for init' do
      it 'inits the destination Terraform configuration' do
        init = stub_ruby_terraform_init
        stub_ruby_terraform_apply

        helper = described_class.new
        helper.execute(
          source_directory: 'path/to/source/configuration',
          configuration_directory: 'path/to/destination/configuration'
        )

        expect(init)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'path/to/destination/configuration'
                      )))
      end

      it 'uses the specified source Terraform configuration ' \
         'as the from_module parameter' do
        init = stub_ruby_terraform_init
        stub_ruby_terraform_apply

        helper = described_class.new
        helper.execute(
          source_directory: 'path/to/source/configuration',
          configuration_directory: 'path/to/destination/configuration'
        )

        expect(init)
          .to(have_received(:execute)
                    .with(hash_including(
                            from_module: 'path/to/source/configuration'
                          )))
      end
    end

    describe 'for apply' do
      it 'applies the destination Terraform configuration' do
        stub_ruby_terraform_init
        apply = stub_ruby_terraform_apply

        helper = described_class.new
        helper.execute(
          source_directory: 'path/to/source/configuration',
          configuration_directory: 'path/to/destination/configuration'
        )

        expect(apply)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'path/to/destination/configuration'
                      )))
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

      helper = described_class.new
      helper.execute(required_parameters)

      expect(init)
        .to(have_received(:execute))
    end

    it 'applies using the specified binary' do
      stub_ruby_terraform_init
      apply = stub_ruby_terraform_apply(binary: terraform_binary)

      helper = described_class.new
      helper.execute(required_parameters)

      expect(apply)
        .to(have_received(:execute))
    end
  end

  context 'when configuration overrides provided' do
    describe 'for init' do
      it 'uses the specified Terraform configuration' do
        init = stub_ruby_terraform_init
        stub_ruby_terraform_apply

        helper = described_class.new
        helper.execute(
          configuration_directory: 'path/to/terraform/configuration'
        )

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

        helper = described_class.new
        helper.execute(
          configuration_directory: 'path/to/terraform/configuration'
        )

        expect(apply)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'path/to/terraform/configuration'
                      )))
      end

      it 'uses the specified state file' do
        stub_ruby_terraform_init
        apply = stub_ruby_terraform_apply

        helper = described_class.new
        helper.execute(
          required_parameters.merge(
            state_file: 'path/to/terraform/state'
          )
        )

        expect(apply)
          .to(have_received(:execute)
                .with(hash_including(
                        state: 'path/to/terraform/state'
                      )))
      end

      it 'uses the specified vars' do
        stub_ruby_terraform_init
        apply = stub_ruby_terraform_apply

        helper = described_class.new
        helper.execute(
          required_parameters.merge(
            vars: {
              first: 1,
              second: 2
            }
          )
        )

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
          configuration_provider: configuration_provider
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
          configuration_provider: configuration_provider
        )
        helper.execute(override_configuration)

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
          configuration_provider: configuration_provider
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
          configuration_provider: configuration_provider
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
          configuration_provider: configuration_provider
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
          configuration_provider: configuration_provider
        )
        helper.execute(override_configuration)

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

      helper = described_class.new
      helper.execute(required_parameters) do |vars|
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

      helper = described_class.new
      helper.execute(
        required_parameters.merge(
          vars: {
            first: 1,
            second: 2
          }
        )
      ) do |vars|
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

      helper = described_class.new
      helper.execute(
        required_parameters.merge(
          vars: {
            first: 1,
            second: 2
          }
        )
      ) do |vars|
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
        configuration_provider: configuration_provider
      )
      helper.execute(required_parameters) do |vars|
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

  def required_parameters(execution_mode: :in_place)
    {
      in_place: { configuration_directory: 'path/to/configuration' },
      isolated: { source_directory: 'path/to/source/configuration',
                  configuration_directory: 'path/to/destination/configuration' }
    }[execution_mode] || {}
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

  def stub_rm_rf
    allow(FileUtils).to(receive(:rm_rf))
  end

  def stub_mkdir_p
    allow(FileUtils).to(receive(:mkdir_p))
  end
end
