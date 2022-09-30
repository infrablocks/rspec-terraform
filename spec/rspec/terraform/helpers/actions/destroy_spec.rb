# frozen_string_literal: true

require 'spec_helper'
require 'logger'

describe RSpec::Terraform::Helpers::Actions::Destroy do
  before do
    stub_ruby_terraform_destroy
  end

  it 'logs at info level when starting destroy' do
    logger = logger_double
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::Destroy
    end
    instance = klass.new(logger: logger)
    configuration_directory = 'path/to/configuration'
    parameters = {
      configuration_directory: configuration_directory
    }

    instance.destroy(parameters)

    expect(logger)
      .to(have_received(:info)
            .with('Destroying for configuration in directory: ' \
                  "'#{configuration_directory}'..."))
  end

  it 'logs at debug level with all parameters' do
    logger = logger_double
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::Destroy
    end
    instance = klass.new(logger: logger)
    state_file = 'path/to/state.tfstate'
    configuration_directory = 'path/to/configuration'
    parameters = {
      configuration_directory: configuration_directory,
      state_file: state_file
    }

    instance.destroy(parameters)

    expected_parameters = {
      chdir: configuration_directory,
      input: false,
      auto_approve: true,
      state: state_file
    }

    expect(logger)
      .to(have_received(:debug)
            .with("Destroying using parameters: #{expected_parameters}..."))
  end

  it 'logs at info level when completing destroy' do
    logger = logger_double
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::Destroy
    end
    instance = klass.new(logger: logger)
    configuration_directory = 'path/to/configuration'
    parameters = {
      configuration_directory: configuration_directory
    }

    instance.destroy(parameters)

    expect(logger)
      .to(have_received(:info)
            .with('Destroy complete.'))
  end

  def logger_double
    logger = instance_double(Logger)
    allow(logger).to(receive(:info))
    allow(logger).to(receive(:debug))
    logger
  end

  def stub_ruby_terraform_destroy
    apply = instance_double(RubyTerraform::Commands::Destroy)
    allow(RubyTerraform::Commands::Destroy)
      .to(receive(:new)
            .and_return(apply))
    allow(apply).to(receive(:execute))
    apply
  end
end
