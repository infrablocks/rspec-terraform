# frozen_string_literal: true

require 'spec_helper'
require 'logger'
require 'stringio'

describe RSpec::Terraform::Logging do
  context 'when logger is provided' do
    it 'uses the provided logger as the logger stream' do
      logger = instance_double(Logger)

      streams = described_class.resolve_streams(logger:)

      expect(streams[:logger]).to(eq(logger))
    end
  end

  context 'when logger is not provided' do
    it 'creates a logger that logs at INFO level by default' do
      stdout = StringIO.new

      streams = described_class.resolve_streams(
        stdout:,
        streams: [:standard]
      )
      logger = streams[:logger]
      logger.debug('less important log message')

      expect(stdout.string)
        .not_to(include('less important log message'))
    end

    it 'creates a logger that logs at the specified level when provided' do
      stdout = StringIO.new

      streams = described_class.resolve_streams(
        stdout:,
        streams: [:standard],
        level: Logger::DEBUG
      )
      logger = streams[:logger]
      logger.debug('less important log message')

      expect(stdout.string)
        .to(include('less important log message'))
    end

    context 'when streams includes only :standard' do
      it 'creates a logger that logs to $stdout when stdout not provided' do
        expect do
          streams = described_class.resolve_streams(streams: [:standard])
          logger = streams[:logger]
          logger.info('important log message')
        end.to(produce_output(including('important log message')).to_stdout)
      end

      it 'creates a logger that logs to specified stdout when provided' do
        stdout = StringIO.new

        streams = described_class.resolve_streams(
          stdout:,
          streams: [:standard]
        )
        logger = streams[:logger]
        logger.info('important log message')

        expect(stdout.string)
          .to(include('important log message'))
      end

      it 'does not make the log file directory when file path provided' do
        file_path = 'some/path/to/file'

        allow(FileUtils).to(receive(:mkdir_p))

        described_class.resolve_streams(
          streams: [:standard],
          file_path:
        )

        expect(FileUtils)
          .not_to(have_received(:mkdir_p)
                .with('some/path/to'))
      end
    end

    context 'when streams includes :file' do
      it 'raises an error when no file path provided' do
        expect { described_class.resolve_streams(streams: [:file]) }
          .to(raise_error(ArgumentError))
      end

      it 'makes the log file directory when file path provided' do
        file = StringIO.new
        file_path = 'some/path/to/file'

        allow(File).to(receive(:open).and_return(file))
        allow(FileUtils).to(receive(:mkdir_p))

        described_class.resolve_streams(
          streams: [:file],
          file_path:
        )

        expect(FileUtils)
          .to(have_received(:mkdir_p)
                .with('some/path/to'))
      end

      it 'creates a logger that logs to the specified file when file path ' \
         'provided' do
        file = StringIO.new
        file_path = 'some/path/to/file'

        allow(File)
          .to(receive(:open)
                .with(file_path, anything)
                .and_return(file))
        allow(FileUtils).to(receive(:mkdir_p))

        streams = described_class.resolve_streams(
          streams: [:file],
          file_path:
        )
        logger = streams[:logger]
        logger.info('important log message')

        expect(file.string).to(include('important log message'))
      end
    end

    context 'when streams includes both :standard and :file' do
      # rubocop:disable RSpec/MultipleExpectations
      it 'creates a logger than logs to both to stdout and file' do
        stdout = StringIO.new
        file = StringIO.new
        file_path = 'some/path/to/file'

        allow(File)
          .to(receive(:open)
                .with(file_path, anything)
                .and_return(file))
        allow(FileUtils).to(receive(:mkdir_p))

        streams = described_class.resolve_streams(
          streams: %i[file standard],
          stdout:,
          file_path:
        )
        logger = streams[:logger]
        logger.info('important log message')

        expect(file.string).to(include('important log message'))
        expect(stdout.string).to(include('important log message'))
      end
      # rubocop:enable RSpec/MultipleExpectations
    end
  end

  context 'when stdout is provided' do
    it 'uses the provided stdout as the stdout stream' do
      stdout = StringIO.new

      streams = described_class.resolve_streams(stdout:)

      expect(streams[:stdout]).to(eq(stdout))
    end

    it 'logs to the provided stdout stream' do
      stdout = StringIO.new

      streams = described_class.resolve_streams(
        stdout:,
        streams: [:standard]
      )
      logger = streams[:logger]
      logger.info('important log message')

      expect(stdout.string)
        .to(include('important log message'))
    end
  end

  context 'when stdout is not provided' do
    context 'when streams includes :standard' do
      it 'creates a stream that writes to $stdout when stdout not provided' do
        expect do
          streams = described_class.resolve_streams(streams: [:standard])
          stdout = streams[:stdout]
          stdout.write('important log message')
        end.to(produce_output(including('important log message')).to_stdout)
      end
    end

    context 'when streams includes :file' do
      it 'raises an error when no file path provided' do
        expect { described_class.resolve_streams(streams: [:file]) }
          .to(raise_error(ArgumentError))
      end

      it 'creates a stream that writes to the specified file when file path ' \
         'provided' do
        file = StringIO.new
        file_path = 'some/path/to/file'

        allow(File)
          .to(receive(:open)
                .with(file_path, anything)
                .and_return(file))
        allow(FileUtils).to(receive(:mkdir_p))

        streams = described_class.resolve_streams(
          streams: [:file],
          file_path:
        )
        stdout = streams[:stdout]
        stdout.write('important log message')

        expect(file.string).to(include('important log message'))
      end
    end

    context 'when streams includes both :standard and :file' do
      # rubocop:disable RSpec/MultipleExpectations
      it 'creates a stream that writes to both to stdout and file' do
        file = StringIO.new
        file_path = 'some/path/to/file'

        allow(File)
          .to(receive(:open)
                .with(file_path, anything)
                .and_return(file))
        allow(FileUtils).to(receive(:mkdir_p))

        expect do
          streams = described_class.resolve_streams(
            streams: %i[file standard],
            file_path:
          )
          logger = streams[:logger]
          logger.info('important log message')
        end.to(produce_output(including('important log message')).to_stdout)

        expect(file.string).to(include('important log message'))
      end
      # rubocop:enable RSpec/MultipleExpectations
    end
  end

  context 'when stderr is provided' do
    it 'uses the provided stderr as the stderr stream' do
      stderr = StringIO.new

      streams = described_class.resolve_streams(stderr:)

      expect(streams[:stderr]).to(eq(stderr))
    end
  end

  context 'when stderr is not provided' do
    context 'when streams includes :standard' do
      it 'creates a stream that writes to $stderr when stderr not provided' do
        expect do
          streams = described_class.resolve_streams(streams: [:standard])
          stderr = streams[:stderr]
          stderr.write('important log message')
        end.to(produce_output(including('important log message')).to_stderr)
      end
    end

    context 'when streams includes :file' do
      it 'raises an error when no file path provided' do
        expect { described_class.resolve_streams(streams: [:file]) }
          .to(raise_error(ArgumentError))
      end

      it 'creates a stream that writes to the specified file when file path ' \
         'provided' do
        file = StringIO.new
        file_path = 'some/path/to/file'

        allow(File)
          .to(receive(:open)
                .with(file_path, anything)
                .and_return(file))
        allow(FileUtils).to(receive(:mkdir_p))

        streams = described_class.resolve_streams(
          streams: [:file],
          file_path:
        )
        stderr = streams[:stderr]
        stderr.write('important log message')

        expect(file.string).to(include('important log message'))
      end
    end

    context 'when streams includes both :standard and :file' do
      # rubocop:disable RSpec/MultipleExpectations
      it 'creates a stream that writes to both to stderr and file' do
        file = StringIO.new
        file_path = 'some/path/to/file'

        allow(File)
          .to(receive(:open)
                .with(file_path, anything)
                .and_return(file))
        allow(FileUtils).to(receive(:mkdir_p))

        expect do
          streams = described_class.resolve_streams(
            streams: %i[file standard],
            file_path:
          )
          stderr = streams[:stderr]
          stderr.write('important log message')
        end.to(produce_output(including('important log message')).to_stderr)

        expect(file.string).to(include('important log message'))
      end
      # rubocop:enable RSpec/MultipleExpectations
    end
  end

  def produce_output(expected)
    RSpec::Matchers::BuiltIn::Output.new(expected)
  end
end
