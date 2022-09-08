# frozen_string_literal: true

module RSpec
  module Terraform
    module Logging
      class << self
        def resolve_streams(opts = {})
          opts = resolve_opts(opts)
          streams = opts[:streams]
          level = opts[:level]
          devices = devices(opts)

          resolve_opts(opts)

          {
            logger: resolve_logger(opts[:logger], streams, devices, level),
            stdout: resolve_stdout(opts[:stdout], streams, devices),
            stderr: resolve_stderr(opts[:stderr], streams, devices)
          }
        end

        private

        def resolve_opts(opts)
          streams = opts[:streams] || []
          level = opts[:level] || Logger::INFO

          if streams.include?(:file) && !opts[:file_path]
            raise(
              ArgumentError,
              'File logging requested but no file path provided'
            )
          end

          opts.merge(streams: streams, level: level)
        end

        def resolve_logger(logger, streams, devices, level)
          return logger if logger

          log_devices = []
          log_devices << devices[:file] if streams.include?(:file)
          log_devices << devices[:stdout] if streams.include?(:standard)

          Logger.new(multi_io(log_devices), level: level)
        end

        def resolve_stdout(stdout, streams, devices)
          return stdout if stdout

          log_devices = []
          log_devices << devices[:file] if streams.include?(:file)
          log_devices << devices[:stdout] if streams.include?(:standard)

          multi_io(log_devices)
        end

        def resolve_stderr(stderr, streams, devices)
          return stderr if stderr

          log_devices = []
          log_devices << devices[:file] if streams.include?(:file)
          log_devices << devices[:stderr] if streams.include?(:standard)

          multi_io(log_devices)
        end

        def devices(opts)
          streams = opts[:streams]
          file_path = opts[:file_path]
          stdout = opts[:stdout]

          {
            file: log_device(resolve_file_path(file_path, streams)),
            stdout: log_device(resolved_stdout(stdout)),
            stderr: log_device(resolved_stderr)
          }
        end

        def resolve_file_path(file_path, streams)
          resolved_file_path = File::NULL
          if streams.include?(:file) && file_path
            FileUtils.mkdir_p(File.dirname(file_path))
            resolved_file_path = file_path
          end
          resolved_file_path
        end

        def resolved_stdout(stdout)
          stdout || $stdout
        end

        def resolved_stderr
          $stderr
        end

        def log_device(io)
          Logger::LogDevice.new(io)
        end

        def multi_io(ios)
          RubyTerraform::MultiIO.new(*ios)
        end
      end
    end
  end
end
