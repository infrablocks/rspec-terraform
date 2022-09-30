# frozen_string_literal: true

require 'spec_helper'
require 'logger'

describe RSpec::Terraform::Helpers::Actions::Output do
  before do
    stub_ruby_terraform_output
  end

  it 'logs at info level when starting output' do
    logger = logger_double
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::Output
    end
    instance = klass.new(logger: logger)
    configuration_directory = 'path/to/configuration'
    parameters = {
      configuration_directory: configuration_directory
    }

    instance.output(parameters)

    expect(logger)
      .to(have_received(:info)
            .with('Outputting for configuration in directory: ' \
                  "'#{configuration_directory}'..."))
  end

  it 'logs at debug level with all parameters' do
    logger = logger_double
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::Output
    end
    instance = klass.new(logger: logger)
    state_file = 'path/to/state.tfstate'
    configuration_directory = 'path/to/configuration'
    parameters = {
      configuration_directory: configuration_directory,
      state_file: state_file
    }

    instance.output(parameters)

    expected_parameters = {
      chdir: configuration_directory,
      state: state_file
    }

    expect(logger)
      .to(have_received(:debug)
            .with("Outputting using parameters: #{expected_parameters}..."))
  end

  it 'logs at info level when completing output' do
    logger = logger_double
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::Output
    end
    instance = klass.new(logger: logger)
    configuration_directory = 'path/to/configuration'
    parameters = {
      configuration_directory: configuration_directory
    }

    instance.output(parameters)

    expect(logger)
      .to(have_received(:info)
            .with('Output complete.'))
  end

  def logger_double
    logger = instance_double(Logger)
    allow(logger).to(receive(:info))
    allow(logger).to(receive(:debug))
    logger
  end

  def stub_ruby_terraform_output
    output = instance_double(RubyTerraform::Commands::Output)
    allow(RubyTerraform::Commands::Output)
      .to(receive(:new)
            .and_return(output))
    allow(output).to(receive(:execute))
    output
  end
end
