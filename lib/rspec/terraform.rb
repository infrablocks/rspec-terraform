# frozen_string_literal: true

require 'rspec/core'
require 'ruby_terraform'

require_relative 'terraform/version'
require_relative 'terraform/configuration'
require_relative 'terraform/matchers'
require_relative 'terraform/helpers'
require_relative 'terraform/logging'

# TODO
# ====
#
# * Logging
# * Test session
# * Before support in matchers
# * Reference support in matchers
# * Sensitive support in matchers
#

# rubocop:disable Metrics/BlockLength
RSpec.configure do |config|
  config.include(RSpec::Terraform::Matchers)
  config.prepend(RSpec::Terraform::Helpers)

  config.add_setting(:terraform_binary, default: 'terraform')

  config.add_setting(:terraform_log_file_path, default: nil)
  config.add_setting(:terraform_log_streams, default: [:standard])

  config.add_setting(:terraform_logger, default: nil)
  config.add_setting(:terraform_stdin, default: nil)
  config.add_setting(:terraform_stdout, default: nil)
  config.add_setting(:terraform_stderr, default: nil)

  config.add_setting(:terraform_execution_mode, default: :in_place)

  config.add_setting(
    :terraform_configuration_provider,
    default: RSpec::Terraform::Configuration.identity_provider
  )

  config.before(:suite) do
    resolved_streams = RSpec::Terraform::Logging.resolve_streams(
      file_path: RSpec.configuration.terraform_log_file_path,
      streams: RSpec.configuration.terraform_log_streams,
      logger: RSpec.configuration.terraform_logger,
      stdout: RSpec.configuration.terraform_stdout,
      stderr: RSpec.configuration.terraform_stderr
    )

    RSpec.configuration.terraform_logger = resolved_streams[:logger]
    RSpec.configuration.terraform_stdout = resolved_streams[:stdout]
    RSpec.configuration.terraform_stderr = resolved_streams[:stderr]
  end
end
# rubocop:enable Metrics/BlockLength

RSpec::Core::AnonymousExampleGroup
  .include(RSpec::Terraform::Helpers)
