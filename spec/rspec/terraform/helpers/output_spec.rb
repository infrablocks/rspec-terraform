# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'stringio'

describe RSpec::Terraform::Helpers::Output do
  before do
    stub_rm_rf
    stub_mkdir_p
  end

  # rubocop:disable RSpec/MultipleExpectations
  it 'invokes init before output' do
    init = stub_ruby_terraform_init
    output = stub_ruby_terraform_output

    helper = described_class_instance
    helper.execute(required_parameters)

    expect(init).to(have_received(:execute).ordered)
    expect(output).to(have_received(:execute).ordered)
  end
  # rubocop:enable RSpec/MultipleExpectations

  it 'returns the output value' do
    stub_ruby_terraform_init
    output_command = stub_ruby_terraform_output

    output_value = { key: 'value' }

    opts = nil
    allow(RubyTerraform::Commands::Output)
      .to(receive(:new) { |o| opts = o }.and_return(output_command))
    allow(output_command)
      .to(receive(:execute) { opts[:stdout].write(JSON.dump(output_value)) })

    helper = described_class_instance
    plan = helper.execute(required_parameters)

    expect(plan).to(eq(output_value))
  end

  describe 'by default' do
    it 'throws if no configuration_directory is provided' do
      stub_ruby_terraform_init
      stub_ruby_terraform_output

      parameters = required_parameters
      parameters.delete(:configuration_directory)

      helper = described_class_instance

      expect { helper.execute(parameters) }
        .to(raise_error(
              StandardError,
              'Required parameter: `:configuration_directory` missing.'
            ))
    end

    it 'throws if no name is provided' do
      stub_ruby_terraform_init
      stub_ruby_terraform_output

      parameters = required_parameters
      parameters.delete(:name)

      helper = described_class_instance

      expect { helper.execute(parameters) }
        .to(raise_error(
              StandardError,
              'Required parameter: `:name` missing.'
            ))
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'does not delete and recreate the configuration directory ' \
       'before invoking Terraform' do
      stub_ruby_terraform_init
      stub_ruby_terraform_output

      helper = described_class_instance
      helper.execute(required_parameters)

      expect(FileUtils).not_to(have_received(:rm_rf))
      expect(FileUtils).not_to(have_received(:mkdir_p))
    end
    # rubocop:enable RSpec/MultipleExpectations

    describe 'for init' do
      it 'instructs Terraform not to request interactive input' do
        init = stub_ruby_terraform_init
        stub_ruby_terraform_output

        helper = described_class_instance
        helper.execute(required_parameters)

        expect(init)
          .to(have_received(:execute)
                .with(hash_including(input: false)))
      end

      it 'inits the specified Terraform configuration in place' do
        init = stub_ruby_terraform_init
        stub_ruby_terraform_output

        helper = described_class_instance
        helper.execute(
          required_parameters.merge(
            configuration_directory: 'path/to/terraform/configuration'
          )
        )

        expect(init)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'path/to/terraform/configuration'
                      )))
      end

      it 'does not include the from_module parameter' do
        init = stub_ruby_terraform_init
        stub_ruby_terraform_output

        helper = described_class_instance
        helper.execute(
          required_parameters.merge(
            configuration_directory: 'path/to/terraform/configuration'
          )
        )

        expect(init)
          .not_to(have_received(:execute)
                    .with(hash_including(:from_module)))
      end

      it 'uses a Terraform binary of "terraform"' do
        init = stub_ruby_terraform_init(binary: 'terraform')
        stub_ruby_terraform_output

        helper = described_class_instance
        helper.execute(required_parameters)

        expect(init)
          .to(have_received(:execute))
      end

      it 'uses a logger of nil' do
        init = stub_ruby_terraform_init(logger: nil)
        stub_ruby_terraform_output

        helper = described_class.new
        helper.execute(required_parameters)

        expect(init)
          .to(have_received(:execute))
      end

      it 'uses a stdin of nil' do
        init = stub_ruby_terraform_init(stdin: nil)
        stub_ruby_terraform_output

        helper = described_class_instance
        helper.execute(required_parameters)

        expect(init)
          .to(have_received(:execute))
      end

      it 'uses a stdout of nil' do
        init = stub_ruby_terraform_init(stdout: nil)
        stub_ruby_terraform_output

        helper = described_class_instance
        helper.execute(required_parameters)

        expect(init)
          .to(have_received(:execute))
      end

      it 'uses a stderr of nil' do
        init = stub_ruby_terraform_init(stderr: nil)
        stub_ruby_terraform_output

        helper = described_class_instance
        helper.execute(required_parameters)

        expect(init)
          .to(have_received(:execute))
      end
    end

    describe 'for output' do
      it 'instructs Terraform to output JSON' do
        stub_ruby_terraform_init
        output = stub_ruby_terraform_output

        helper = described_class_instance
        helper.execute(required_parameters)

        expect(output)
          .to(have_received(:execute)
                .with(hash_including(json: true)))
      end

      it 'does not specify a state file' do
        stub_ruby_terraform_init
        output = stub_ruby_terraform_output

        helper = described_class_instance
        helper.execute(required_parameters)

        expect(output)
          .not_to(have_received(:execute)
                    .with(hash_including(:state)))
      end

      it 'specifies an output name' do
        stub_ruby_terraform_init
        output = stub_ruby_terraform_output

        helper = described_class_instance
        helper.execute(required_parameters)

        expect(output)
          .to(have_received(:execute)
                .with(hash_including(:name)))
      end

      it 'outputs using the specified Terraform configuration in place' do
        stub_ruby_terraform_init
        output = stub_ruby_terraform_output

        helper = described_class_instance
        helper.execute(
          required_parameters.merge(
            configuration_directory: 'path/to/terraform/configuration'
          )
        )

        expect(output)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'path/to/terraform/configuration'
                      )))
      end

      it 'uses a Terraform binary of "terraform"' do
        stub_ruby_terraform_init
        output = stub_ruby_terraform_output(binary: 'terraform')

        helper = described_class_instance
        helper.execute(required_parameters)

        expect(output)
          .to(have_received(:execute))
      end

      it 'uses a logger of nil' do
        stub_ruby_terraform_init
        output = stub_ruby_terraform_output(logger: nil)

        helper = described_class_instance
        helper.execute(required_parameters)

        expect(output)
          .to(have_received(:execute))
      end

      it 'uses a stdin of nil' do
        stub_ruby_terraform_init
        output = stub_ruby_terraform_output(stdin: nil)

        helper = described_class_instance
        helper.execute(required_parameters)

        expect(output)
          .to(have_received(:execute))
      end

      it 'uses a stderr of nil' do
        stub_ruby_terraform_init
        output = stub_ruby_terraform_output(stderr: nil)

        helper = described_class_instance
        helper.execute(required_parameters)

        expect(output)
          .to(have_received(:execute))
      end
    end
  end

  context 'when Terraform execution mode is :in_place' do
    it 'throws if no configuration_directory is provided' do
      stub_ruby_terraform_init
      stub_ruby_terraform_output

      parameters = required_parameters(execution_mode: :in_place)
      parameters.delete(:configuration_directory)

      helper = described_class_instance(execution_mode: :in_place)

      expect { helper.execute(parameters) }
        .to(raise_error(
              StandardError,
              'Required parameter: `:configuration_directory` missing.'
            ))
    end

    it 'throws if no name is provided' do
      stub_ruby_terraform_init
      stub_ruby_terraform_output

      parameters = required_parameters(execution_mode: :in_place)
      parameters.delete(:name)

      helper = described_class_instance(execution_mode: :in_place)

      expect { helper.execute(parameters) }
        .to(raise_error(
              StandardError,
              'Required parameter: `:name` missing.'
            ))
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'does not delete and recreate the configuration directory ' \
       'before invoking Terraform' do
      stub_ruby_terraform_init
      stub_ruby_terraform_output

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
        stub_ruby_terraform_output

        helper = described_class_instance(execution_mode: :in_place)
        helper.execute(
          required_parameters.merge(
            configuration_directory: 'path/to/terraform/configuration'
          )
        )

        expect(init)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'path/to/terraform/configuration'
                      )))
      end

      it 'does not include the from_module parameter' do
        init = stub_ruby_terraform_init
        stub_ruby_terraform_output

        helper = described_class_instance(execution_mode: :in_place)
        helper.execute(
          required_parameters.merge(
            configuration_directory: 'path/to/terraform/configuration'
          )
        )

        expect(init)
          .not_to(have_received(:execute)
                    .with(hash_including(:from_module)))
      end
    end

    describe 'for output' do
      it 'outputs using the specified Terraform configuration in place' do
        stub_ruby_terraform_init
        output = stub_ruby_terraform_output

        helper = described_class_instance(execution_mode: :in_place)
        helper.execute(
          required_parameters.merge(
            configuration_directory: 'path/to/terraform/configuration'
          )
        )

        expect(output)
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
      stub_ruby_terraform_output

      parameters = required_parameters(execution_mode: :isolated)
      parameters.delete(:configuration_directory)

      helper = described_class_instance(execution_mode: :isolated)

      expect { helper.execute(parameters) }
        .to(raise_error(
              StandardError,
              'Required parameter: `:configuration_directory` missing.'
            ))
    end

    it 'throws if no source_directory is provided' do
      stub_ruby_terraform_init
      stub_ruby_terraform_output

      parameters = required_parameters(execution_mode: :isolated)
      parameters.delete(:source_directory)

      helper = described_class_instance(execution_mode: :isolated)

      expect { helper.execute(parameters) }
        .to(raise_error(
              StandardError,
              'Required parameter: `:source_directory` missing.'
            ))
    end

    it 'throws if no name is provided' do
      stub_ruby_terraform_init
      stub_ruby_terraform_output

      parameters = required_parameters(execution_mode: :isolated)
      parameters.delete(:name)

      helper = described_class_instance(execution_mode: :isolated)

      expect { helper.execute(parameters) }
        .to(raise_error(
              StandardError,
              'Required parameter: `:name` missing.'
            ))
    end

    it 'throws if no required parameters provided' do
      stub_ruby_terraform_init
      stub_ruby_terraform_output

      helper = described_class_instance(execution_mode: :isolated)

      expect { helper.execute }
        .to(raise_error(
              StandardError,
              'Required parameters: `:name`, `:source_directory` and ' \
              '`:configuration_directory` missing.'
            ))
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'deletes and recreates the configuration directory ' \
       'before invoking Terraform' do
      init = stub_ruby_terraform_init
      output = stub_ruby_terraform_output

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
      expect(output).to(have_received(:execute).ordered)
    end
    # rubocop:enable RSpec/MultipleExpectations

    describe 'for init' do
      it 'inits the destination Terraform configuration' do
        init = stub_ruby_terraform_init
        stub_ruby_terraform_output

        helper = described_class_instance(execution_mode: :isolated)
        helper.execute(
          required_parameters.merge(
            source_directory: 'path/to/source/configuration',
            configuration_directory: 'path/to/destination/configuration'
          )
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
        stub_ruby_terraform_output

        helper = described_class_instance(execution_mode: :isolated)
        helper.execute(
          required_parameters.merge(
            source_directory: 'path/to/source/configuration',
            configuration_directory: 'path/to/destination/configuration'
          )
        )

        expect(init)
          .to(have_received(:execute)
                .with(hash_including(
                        from_module: 'path/to/source/configuration'
                      )))
      end
    end

    describe 'for output' do
      it 'outputs using the destination Terraform configuration' do
        stub_ruby_terraform_init
        output = stub_ruby_terraform_output

        helper = described_class_instance(execution_mode: :isolated)
        helper.execute(
          required_parameters.merge(
            source_directory: 'path/to/source/configuration',
            configuration_directory: 'path/to/destination/configuration'
          )
        )

        expect(output)
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
      stub_ruby_terraform_output

      helper = described_class_instance(binary: 'path/to/binary')
      helper.execute(required_parameters)

      expect(init)
        .to(have_received(:execute))
    end

    it 'outputs using the specified binary' do
      stub_ruby_terraform_init
      output = stub_ruby_terraform_output(binary: 'path/to/binary')

      helper = described_class_instance(binary: 'path/to/binary')
      helper.execute(required_parameters)

      expect(output)
        .to(have_received(:execute))
    end
  end

  context 'when logger overridden' do
    it 'inits using the specified logger' do
      logger = logger_double

      init = stub_ruby_terraform_init(logger: logger)
      stub_ruby_terraform_output

      helper = described_class_instance(logger: logger)
      helper.execute(required_parameters)

      expect(init)
        .to(have_received(:execute))
    end

    it 'applies using the specified logger' do
      logger = logger_double

      stub_ruby_terraform_init
      output = stub_ruby_terraform_output(logger: logger)

      helper = described_class_instance(logger: logger)
      helper.execute(required_parameters)

      expect(output)
        .to(have_received(:execute))
    end
  end

  context 'when stdin overridden' do
    it 'inits using the specified stdin' do
      stdin = StringIO.new

      init = stub_ruby_terraform_init(stdin: stdin)
      stub_ruby_terraform_output

      helper = described_class_instance(stdin: stdin)
      helper.execute(required_parameters)

      expect(init)
        .to(have_received(:execute))
    end

    it 'applies using the specified stdin' do
      stdin = StringIO.new

      stub_ruby_terraform_init
      output = stub_ruby_terraform_output(stdin: stdin)

      helper = described_class_instance(stdin: stdin)
      helper.execute(required_parameters)

      expect(output)
        .to(have_received(:execute))
    end
  end

  context 'when stdout overridden' do
    it 'inits using the specified stdout' do
      stdout = StringIO.new

      init = stub_ruby_terraform_init(stdout: stdout)
      stub_ruby_terraform_output

      helper = described_class_instance(stdout: stdout)
      helper.execute(required_parameters)

      expect(init)
        .to(have_received(:execute))
    end
  end

  context 'when stderr overridden' do
    it 'inits using the specified stderr' do
      stderr = StringIO.new

      init = stub_ruby_terraform_init(stderr: stderr)
      stub_ruby_terraform_output

      helper = described_class_instance(stderr: stderr)
      helper.execute(required_parameters)

      expect(init)
        .to(have_received(:execute))
    end

    it 'applies using the specified stderr' do
      stderr = StringIO.new

      stub_ruby_terraform_init
      output = stub_ruby_terraform_output(stderr: stderr)

      helper = described_class_instance(stderr: stderr)
      helper.execute(required_parameters)

      expect(output)
        .to(have_received(:execute))
    end
  end

  context 'when configuration overrides provided' do
    describe 'for init' do
      it 'uses the specified Terraform configuration' do
        init = stub_ruby_terraform_init
        stub_ruby_terraform_output

        helper = described_class_instance
        helper.execute(
          required_parameters.merge(
            configuration_directory: 'path/to/terraform/configuration'
          )
        )

        expect(init)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'path/to/terraform/configuration'
                      )))
      end
    end

    describe 'for output' do
      it 'uses the specified Terraform configuration' do
        stub_ruby_terraform_init
        output = stub_ruby_terraform_output

        helper = described_class_instance
        helper.execute(
          required_parameters.merge(
            configuration_directory: 'path/to/terraform/configuration'
          )
        )

        expect(output)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'path/to/terraform/configuration'
                      )))
      end

      it 'uses the specified state file' do
        stub_ruby_terraform_init
        output = stub_ruby_terraform_output

        helper = described_class_instance
        helper.execute(
          required_parameters.merge(
            state_file: 'path/to/terraform/state'
          )
        )

        expect(output)
          .to(have_received(:execute)
                .with(hash_including(
                        state: 'path/to/terraform/state'
                      )))
      end
    end
  end

  context 'when configuration provider supplied' do
    describe 'for init' do
      it 'uses the Terraform configuration returned by the provider' do
        init = stub_ruby_terraform_init
        stub_ruby_terraform_output

        configuration_provider =
          RSpec::Terraform::Configuration.in_memory_provider(
            required_parameters.merge(
              required_parameters.merge(
                configuration_directory: 'provided/terraform/configuration'
              )
            )
          )

        helper = described_class_instance(
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
        stub_ruby_terraform_output

        in_memory_configuration = required_parameters.merge(
          {
            configuration_directory: 'provided/terraform/configuration'
          }
        )
        override_configuration = required_parameters.merge(
          {
            configuration_directory: 'override/terraform/configuration'
          }
        )
        configuration_provider =
          RSpec::Terraform::Configuration.in_memory_provider(
            in_memory_configuration
          )

        helper = described_class_instance(
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

    describe 'for output' do
      it 'uses the Terraform configuration returned by the provider' do
        stub_ruby_terraform_init
        output = stub_ruby_terraform_output

        configuration_provider =
          RSpec::Terraform::Configuration.in_memory_provider(
            required_parameters.merge(
              configuration_directory: 'provided/terraform/configuration'
            )
          )

        helper = described_class_instance(
          configuration_provider: configuration_provider
        )
        helper.execute

        expect(output)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'provided/terraform/configuration'
                      )))
      end

      it 'uses the state file returned by the provider' do
        stub_ruby_terraform_init
        output = stub_ruby_terraform_output

        configuration_provider =
          RSpec::Terraform::Configuration.in_memory_provider(
            required_parameters.merge(
              state_file: 'provided/terraform/state'
            )
          )

        helper = described_class_instance(
          configuration_provider: configuration_provider
        )
        helper.execute

        expect(output)
          .to(have_received(:execute)
                .with(hash_including(
                        state: 'provided/terraform/state'
                      )))
      end

      it 'uses the name returned by the provider' do
        stub_ruby_terraform_init
        output = stub_ruby_terraform_output

        configuration_provider =
          RSpec::Terraform::Configuration.in_memory_provider(
            required_parameters.merge(
              name: 'provided-output-name'
            )
          )

        helper = described_class_instance(
          configuration_provider: configuration_provider
        )
        helper.execute

        expect(output)
          .to(have_received(:execute)
                .with(hash_including(
                        name: 'provided-output-name'
                      )))
      end

      it 'passes configuration overrides to the provider when present' do
        stub_ruby_terraform_init
        output = stub_ruby_terraform_output

        in_memory_configuration = {
          configuration_directory: 'provided/terraform/configuration',
          state_file: 'provided/state/file',
          name: 'provided-output-name'
        }
        override_configuration = {
          configuration_directory: 'override/terraform/configuration',
          state_file: 'override/state/file',
          name: 'override-output-name'
        }
        configuration_provider =
          RSpec::Terraform::Configuration.in_memory_provider(
            in_memory_configuration
          )

        helper = described_class_instance(
          configuration_provider: configuration_provider
        )
        helper.execute(override_configuration)

        expect(output)
          .to(have_received(:execute)
                .with(hash_including(
                        chdir: 'override/terraform/configuration',
                        state: 'override/state/file',
                        name: 'override-output-name'
                      )))
      end
    end
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

  # rubocop:disable Metrics/MethodLength
  def required_parameters(execution_mode: :in_place)
    {
      in_place: {
        configuration_directory: 'path/to/configuration',
        name: 'output_name'
      },
      isolated: {
        source_directory: 'path/to/source/configuration',
        configuration_directory: 'path/to/destination/configuration',
        name: 'output_name'
      }
    }[execution_mode] || {}
  end
  # rubocop:enable Metrics/MethodLength

  def stub_ruby_terraform_init(opts = nil)
    init = instance_double(RubyTerraform::Commands::Init)
    allow(init).to(receive(:execute))

    expectation = receive(:new)
    expectation = expectation.with(hash_including(opts)) if opts
    expectation = expectation.and_return(init)
    allow(RubyTerraform::Commands::Init).to(expectation)

    init
  end

  def stub_ruby_terraform_output(opts = nil)
    output = instance_double(RubyTerraform::Commands::Output)

    stdout = nil
    expectation = receive(:new) { |o| stdout = o[:stdout] }
    expectation = expectation.with(hash_including(opts)) if opts
    expectation = expectation.and_return(output)
    allow(RubyTerraform::Commands::Output).to(expectation)

    allow(output).to(receive(:execute) { stdout&.write('{}') })

    output
  end

  def stub_rm_rf
    allow(FileUtils).to(receive(:rm_rf))
  end

  def stub_mkdir_p
    allow(FileUtils).to(receive(:mkdir_p))
  end
end
