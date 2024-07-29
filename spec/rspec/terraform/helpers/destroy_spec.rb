# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'stringio'

describe RSpec::Terraform::Helpers::Destroy do
  before do
    stub_rm_rf
    stub_mkdir_p
  end

  # rubocop:disable RSpec/MultipleExpectations
  it 'invokes init before destroy' do
    init = stub_ruby_terraform_init
    destroy = stub_ruby_terraform_destroy

    helper = described_class_instance
    helper.execute(required_parameters)

    expect(init).to(have_received(:execute).ordered)
    expect(destroy).to(have_received(:execute).ordered)
  end
  # rubocop:enable RSpec/MultipleExpectations

  describe 'by default' do
    it 'throws if no configuration_directory is provided' do
      stub_ruby_terraform_init
      stub_ruby_terraform_destroy

      helper = described_class_instance

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
      stub_ruby_terraform_destroy

      helper = described_class_instance
      helper.execute(required_parameters)

      expect(FileUtils).not_to(have_received(:rm_rf))
      expect(FileUtils).not_to(have_received(:mkdir_p))
    end
    # rubocop:enable RSpec/MultipleExpectations

    describe 'for init' do
      it 'instructs Terraform not to request interactive input' do
        init = stub_ruby_terraform_init
        stub_ruby_terraform_destroy

        helper = described_class_instance
        helper.execute(required_parameters)

        expect(init)
          .to(have_received(:execute)
                .with(hash_including(input: false)))
      end

      it 'inits the specified Terraform configuration in place' do
        init = stub_ruby_terraform_init
        stub_ruby_terraform_destroy

        helper = described_class_instance
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
        stub_ruby_terraform_destroy

        helper = described_class_instance
        helper.execute(
          configuration_directory: 'path/to/terraform/configuration'
        )

        expect(init)
          .not_to(have_received(:execute)
                    .with(hash_including(:from_module)))
      end

      it 'uses a Terraform binary of "terraform"' do
        init = stub_ruby_terraform_init(binary: 'terraform')
        stub_ruby_terraform_destroy

        helper = described_class_instance
        helper.execute(required_parameters)

        expect(init)
          .to(have_received(:execute))
      end

      it 'uses a logger of nil' do
        init = stub_ruby_terraform_init(logger: nil)
        stub_ruby_terraform_destroy

        helper = described_class.new
        helper.execute(required_parameters)

        expect(init)
          .to(have_received(:execute))
      end

      it 'uses a stdin of nil' do
        init = stub_ruby_terraform_init(stdin: nil)
        stub_ruby_terraform_destroy

        helper = described_class_instance
        helper.execute(required_parameters)

        expect(init)
          .to(have_received(:execute))
      end

      it 'uses a stdout of nil' do
        init = stub_ruby_terraform_init(stdout: nil)
        stub_ruby_terraform_destroy

        helper = described_class_instance
        helper.execute(required_parameters)

        expect(init)
          .to(have_received(:execute))
      end

      it 'uses a stderr of nil' do
        init = stub_ruby_terraform_init(stderr: nil)
        stub_ruby_terraform_destroy

        helper = described_class_instance
        helper.execute(required_parameters)

        expect(init)
          .to(have_received(:execute))
      end
    end

    describe 'for destroy' do
      it 'instructs Terraform not to request interactive input' do
        stub_ruby_terraform_init
        destroy = stub_ruby_terraform_destroy

        helper = described_class_instance
        helper.execute(required_parameters)

        expect(destroy)
          .to(have_received(:execute)
                .with(hash_including(input: false)))
      end

      it 'instructs Terraform to auto approve the plan' do
        stub_ruby_terraform_init
        destroy = stub_ruby_terraform_destroy

        helper = described_class_instance
        helper.execute(required_parameters)

        expect(destroy)
          .to(have_received(:execute)
                .with(hash_including(auto_approve: true)))
      end

      it 'does not specify a state file' do
        stub_ruby_terraform_init
        destroy = stub_ruby_terraform_destroy

        helper = described_class_instance
        helper.execute(required_parameters)

        expect(destroy)
          .not_to(have_received(:execute)
                    .with(hash_including(:state)))
      end

      it 'destroys the specified Terraform configuration in place' do
        stub_ruby_terraform_init
        destroy = stub_ruby_terraform_destroy

        helper = described_class_instance
        helper.execute(
          configuration_directory: 'path/to/terraform/configuration'
        )

        expect(destroy)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'path/to/terraform/configuration'
                      )))
      end

      it 'uses a Terraform binary of "terraform"' do
        stub_ruby_terraform_init
        destroy = stub_ruby_terraform_destroy(binary: 'terraform')

        helper = described_class_instance
        helper.execute(required_parameters)

        expect(destroy)
          .to(have_received(:execute))
      end

      it 'uses a logger of nil' do
        stub_ruby_terraform_init
        destroy = stub_ruby_terraform_destroy(logger: nil)

        helper = described_class_instance
        helper.execute(required_parameters)

        expect(destroy)
          .to(have_received(:execute))
      end

      it 'uses a stdin of nil' do
        stub_ruby_terraform_init
        destroy = stub_ruby_terraform_destroy(stdin: nil)

        helper = described_class_instance
        helper.execute(required_parameters)

        expect(destroy)
          .to(have_received(:execute))
      end

      it 'uses a stdout of nil' do
        stub_ruby_terraform_init
        destroy = stub_ruby_terraform_destroy(stdout: nil)

        helper = described_class_instance
        helper.execute(required_parameters)

        expect(destroy)
          .to(have_received(:execute))
      end

      it 'uses a stderr of nil' do
        stub_ruby_terraform_init
        destroy = stub_ruby_terraform_destroy(stderr: nil)

        helper = described_class_instance
        helper.execute(required_parameters)

        expect(destroy)
          .to(have_received(:execute))
      end
    end
  end

  context 'when Terraform execution mode is :in_place' do
    it 'throws if no configuration_directory is provided' do
      stub_ruby_terraform_init
      stub_ruby_terraform_destroy

      helper = described_class_instance(execution_mode: :in_place)

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
      stub_ruby_terraform_destroy

      helper = described_class_instance(execution_mode: :in_place)
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
        stub_ruby_terraform_destroy

        helper = described_class_instance(execution_mode: :in_place)
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
        stub_ruby_terraform_destroy

        helper = described_class_instance(execution_mode: :in_place)
        helper.execute(
          configuration_directory: 'path/to/terraform/configuration'
        )

        expect(init)
          .not_to(have_received(:execute)
                    .with(hash_including(:from_module)))
      end
    end

    describe 'for destroy' do
      it 'destroys the specified Terraform configuration in place' do
        stub_ruby_terraform_init
        destroy = stub_ruby_terraform_destroy

        helper = described_class_instance(execution_mode: :in_place)
        helper.execute(
          configuration_directory: 'path/to/terraform/configuration'
        )

        expect(destroy)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'path/to/terraform/configuration'
                      )))
      end
    end
  end

  context 'when Terraform execution mode is :isolated' do
    it 'throws if no configuration_directory is provided' do
      stub_ruby_terraform_init
      stub_ruby_terraform_destroy

      helper = described_class_instance(execution_mode: :isolated)

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
      stub_ruby_terraform_destroy

      helper = described_class_instance(execution_mode: :isolated)

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
      stub_ruby_terraform_destroy

      helper = described_class_instance(execution_mode: :isolated)

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
      destroy = stub_ruby_terraform_destroy

      helper = described_class_instance(execution_mode: :isolated)
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
      expect(destroy).to(have_received(:execute).ordered)
    end
    # rubocop:enable RSpec/MultipleExpectations

    describe 'for init' do
      it 'inits the destination Terraform configuration' do
        init = stub_ruby_terraform_init
        stub_ruby_terraform_destroy

        helper = described_class_instance(execution_mode: :isolated)
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
        stub_ruby_terraform_destroy

        helper = described_class_instance(execution_mode: :isolated)
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

    describe 'for destroy' do
      it 'destroys the destination Terraform configuration' do
        stub_ruby_terraform_init
        destroy = stub_ruby_terraform_destroy

        helper = described_class_instance(execution_mode: :isolated)
        helper.execute(
          source_directory: 'path/to/source/configuration',
          configuration_directory: 'path/to/destination/configuration'
        )

        expect(destroy)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'path/to/destination/configuration'
                      )))
      end
    end
  end

  context 'when Terraform binary overridden' do
    it 'inits using the specified binary' do
      init = stub_ruby_terraform_init(binary: 'path/to/binary')
      stub_ruby_terraform_destroy

      helper = described_class_instance(binary: 'path/to/binary')
      helper.execute(required_parameters)

      expect(init)
        .to(have_received(:execute))
    end

    it 'destroys using the specified binary' do
      stub_ruby_terraform_init
      destroy = stub_ruby_terraform_destroy(binary: 'path/to/binary')

      helper = described_class_instance(binary: 'path/to/binary')
      helper.execute(required_parameters)

      expect(destroy)
        .to(have_received(:execute))
    end
  end

  context 'when logger overridden' do
    it 'inits using the specified logger' do
      logger = logger_double

      init = stub_ruby_terraform_init(logger:)
      stub_ruby_terraform_destroy

      helper = described_class_instance(logger:)
      helper.execute(required_parameters)

      expect(init)
        .to(have_received(:execute))
    end

    it 'applies using the specified logger' do
      logger = logger_double

      stub_ruby_terraform_init
      destroy = stub_ruby_terraform_destroy(logger:)

      helper = described_class_instance(logger:)
      helper.execute(required_parameters)

      expect(destroy)
        .to(have_received(:execute))
    end
  end

  context 'when stdin overridden' do
    it 'inits using the specified stdin' do
      stdin = StringIO.new

      init = stub_ruby_terraform_init(stdin:)
      stub_ruby_terraform_destroy

      helper = described_class_instance(stdin:)
      helper.execute(required_parameters)

      expect(init)
        .to(have_received(:execute))
    end

    it 'applies using the specified stdin' do
      stdin = StringIO.new

      stub_ruby_terraform_init
      destroy = stub_ruby_terraform_destroy(stdin:)

      helper = described_class_instance(stdin:)
      helper.execute(required_parameters)

      expect(destroy)
        .to(have_received(:execute))
    end
  end

  context 'when stdout overridden' do
    it 'inits using the specified stdout' do
      stdout = StringIO.new

      init = stub_ruby_terraform_init(stdout:)
      stub_ruby_terraform_destroy

      helper = described_class_instance(stdout:)
      helper.execute(required_parameters)

      expect(init)
        .to(have_received(:execute))
    end

    it 'applies using the specified stdout' do
      stdout = StringIO.new

      stub_ruby_terraform_init
      destroy = stub_ruby_terraform_destroy(stdout:)

      helper = described_class_instance(stdout:)
      helper.execute(required_parameters)

      expect(destroy)
        .to(have_received(:execute))
    end
  end

  context 'when stderr overridden' do
    it 'inits using the specified stderr' do
      stderr = StringIO.new

      init = stub_ruby_terraform_init(stderr:)
      stub_ruby_terraform_destroy

      helper = described_class_instance(stderr:)
      helper.execute(required_parameters)

      expect(init)
        .to(have_received(:execute))
    end

    it 'applies using the specified stderr' do
      stderr = StringIO.new

      stub_ruby_terraform_init
      destroy = stub_ruby_terraform_destroy(stderr:)

      helper = described_class_instance(stderr:)
      helper.execute(required_parameters)

      expect(destroy)
        .to(have_received(:execute))
    end
  end

  context 'when configuration overrides provided' do
    describe 'for init' do
      it 'uses the specified Terraform configuration' do
        init = stub_ruby_terraform_init
        stub_ruby_terraform_destroy

        helper = described_class_instance
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

    describe 'for destroy' do
      it 'uses the specified Terraform configuration' do
        stub_ruby_terraform_init
        destroy = stub_ruby_terraform_destroy

        helper = described_class_instance
        helper.execute(
          configuration_directory: 'path/to/terraform/configuration'
        )

        expect(destroy)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'path/to/terraform/configuration'
                      )))
      end

      it 'uses the specified state file' do
        stub_ruby_terraform_init
        destroy = stub_ruby_terraform_destroy

        helper = described_class_instance
        helper.execute(
          required_parameters.merge(
            state_file: 'path/to/terraform/state'
          )
        )

        expect(destroy)
          .to(have_received(:execute)
                .with(hash_including(
                        state: 'path/to/terraform/state'
                      )))
      end

      it 'uses the specified vars' do
        stub_ruby_terraform_init
        destroy = stub_ruby_terraform_destroy

        helper = described_class_instance
        helper.execute(
          required_parameters.merge(
            vars: {
              first: 1,
              second: 2
            }
          )
        )

        expect(destroy)
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
        stub_ruby_terraform_destroy

        configuration_provider =
          RSpec::Terraform::Configuration.in_memory_provider(
            configuration_directory: 'provided/terraform/configuration'
          )

        helper = described_class_instance(
          configuration_provider:
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
        stub_ruby_terraform_destroy

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

        helper = described_class_instance(
          configuration_provider:
        )
        helper.execute(override_configuration)

        expect(init)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'override/terraform/configuration'
                      )))
      end
    end

    describe 'for destroy' do
      it 'uses the Terraform configuration returned by the provider' do
        stub_ruby_terraform_init
        destroy = stub_ruby_terraform_destroy

        configuration_provider =
          RSpec::Terraform::Configuration.in_memory_provider(
            configuration_directory: 'provided/terraform/configuration'
          )

        helper = described_class_instance(
          configuration_provider:
        )
        helper.execute

        expect(destroy)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'provided/terraform/configuration'
                      )))
      end

      it 'uses the state file returned by the provider' do
        stub_ruby_terraform_init
        destroy = stub_ruby_terraform_destroy

        configuration_provider =
          RSpec::Terraform::Configuration.in_memory_provider(
            required_parameters.merge(
              state_file: 'provided/terraform/state'
            )
          )

        helper = described_class_instance(
          configuration_provider:
        )
        helper.execute

        expect(destroy)
          .to(have_received(:execute)
                .with(hash_including(
                        state: 'provided/terraform/state'
                      )))
      end

      it 'uses the vars returned by the provider' do
        stub_ruby_terraform_init
        destroy = stub_ruby_terraform_destroy

        configuration_provider =
          RSpec::Terraform::Configuration.in_memory_provider(
            required_parameters.merge(
              vars: {
                first: 1,
                second: 2
              }
            )
          )

        helper = described_class_instance(
          configuration_provider:
        )
        helper.execute

        expect(destroy)
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
        destroy = stub_ruby_terraform_destroy

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

        helper = described_class_instance(
          configuration_provider:
        )
        helper.execute(override_configuration)

        expect(destroy)
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
    it 'passes the vars configured in the block to destroy' do
      stub_ruby_terraform_init
      destroy = stub_ruby_terraform_destroy

      helper = described_class_instance
      helper.execute(required_parameters) do |vars|
        vars.first = 1
        vars.second = 2
      end

      expect(destroy)
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
      destroy = stub_ruby_terraform_destroy

      helper = described_class_instance
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

      expect(destroy)
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
      destroy = stub_ruby_terraform_destroy

      helper = described_class_instance
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

      expect(destroy)
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
      destroy = stub_ruby_terraform_destroy

      configuration_provider =
        RSpec::Terraform::Configuration.in_memory_provider(
          vars: {
            first: 1,
            second: 2
          }
        )

      helper = described_class_instance(
        configuration_provider:
      )
      helper.execute(required_parameters) do |vars|
        vars.second = 'two'
        vars.third = 'three'
      end

      expect(destroy)
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

  context 'when only_if provided' do
    # rubocop:disable RSpec/MultipleExpectations
    it 'does not execute terraform commands when only_if with no arguments ' \
       'returns false' do
      init = stub_ruby_terraform_init
      destroy = stub_ruby_terraform_destroy

      helper = described_class_instance
      helper.execute(
        required_parameters
          .merge(only_if: -> { false })
      )

      expect(init).not_to(have_received(:execute))
      expect(destroy).not_to(have_received(:execute))
    end
    # rubocop:enable RSpec/MultipleExpectations

    # rubocop:disable RSpec/MultipleExpectations
    it 'does not execute terraform commands when only_if with parameters ' \
       'argument returns false' do
      init = stub_ruby_terraform_init
      destroy = stub_ruby_terraform_destroy

      helper = described_class_instance
      helper.execute(
        required_parameters
          .merge(
            some_condition: false,
            only_if: ->(parameters) { parameters[:some_condition] }
          )
      )

      expect(init).not_to(have_received(:execute))
      expect(destroy).not_to(have_received(:execute))
    end
    # rubocop:enable RSpec/MultipleExpectations

    # rubocop:disable RSpec/MultipleExpectations
    it 'executes terraform commands when only_if with no arguments ' \
       'returns true' do
      init = stub_ruby_terraform_init
      destroy = stub_ruby_terraform_destroy

      helper = described_class_instance
      helper.execute(
        required_parameters
          .merge(only_if: -> { true })
      )

      expect(init).to(have_received(:execute))
      expect(destroy).to(have_received(:execute))
    end
    # rubocop:enable RSpec/MultipleExpectations

    # rubocop:disable RSpec/MultipleExpectations
    it 'executes terraform commands when only_if with parameters ' \
       'returns true' do
      init = stub_ruby_terraform_init
      destroy = stub_ruby_terraform_destroy

      helper = described_class_instance
      helper.execute(
        required_parameters
          .merge(
            some_condition: true,
            only_if: ->(parameters) { parameters[:some_condition] }
          )
      )

      expect(init).to(have_received(:execute))
      expect(destroy).to(have_received(:execute))
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  def logger_double
    logger = instance_double(Logger)
    allow(logger).to(receive(:info))
    allow(logger).to(receive(:debug))
    logger
  end

  def described_class_instance(opts = {})
    described_class.new(opts)
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
    expectation = expectation.with(hash_including(opts)) if opts
    expectation = expectation.and_return(init)
    allow(RubyTerraform::Commands::Init).to(expectation)

    init
  end

  def stub_ruby_terraform_destroy(opts = nil)
    destroy = instance_double(RubyTerraform::Commands::Destroy)
    allow(destroy).to(receive(:execute))

    expectation = receive(:new)
    expectation = expectation.with(hash_including(opts)) if opts
    expectation = expectation.and_return(destroy)
    allow(RubyTerraform::Commands::Destroy).to(expectation)

    destroy
  end

  def stub_rm_rf
    allow(FileUtils).to(receive(:rm_rf))
  end

  def stub_mkdir_p
    allow(FileUtils).to(receive(:mkdir_p))
  end
end
