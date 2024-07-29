# frozen_string_literal: true

require 'spec_helper'
require 'logger'

describe RSpec::Terraform::Helpers::Actions::Plan do
  before do
    stub_ruby_terraform_plan
  end

  it 'logs at info level when starting plan' do
    logger = logger_double
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::Plan
    end
    instance = klass.new(logger:)
    configuration_directory = 'path/to/configuration'
    parameters = {
      configuration_directory:
    }

    instance.plan(parameters)

    expect(logger)
      .to(have_received(:info)
            .with('Planning for configuration in directory: ' \
                  "'#{configuration_directory}'..."))
  end

  it 'logs at debug level with all parameters' do
    logger = logger_double
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::Plan
    end
    instance = klass.new(logger:)
    state_file = 'path/to/state.tfstate'
    configuration_directory = 'path/to/configuration'
    parameters = {
      configuration_directory:,
      state_file:
    }

    out = instance.plan(parameters)

    expected_parameters = {
      chdir: configuration_directory,
      out:,
      input: false,
      state: state_file
    }

    expect(logger)
      .to(have_received(:debug)
            .with("Planning using parameters: #{expected_parameters}..."))
  end

  it 'logs at info level when completing plan' do
    logger = logger_double
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::Plan
    end
    instance = klass.new(logger:)
    configuration_directory = 'path/to/configuration'
    parameters = {
      configuration_directory:
    }

    instance.plan(parameters)

    expect(logger)
      .to(have_received(:info)
            .with('Plan complete.'))
  end

  def logger_double
    logger = instance_double(Logger)
    allow(logger).to(receive(:info))
    allow(logger).to(receive(:debug))
    logger
  end

  def stub_ruby_terraform_plan
    plan = instance_double(RubyTerraform::Commands::Plan)
    allow(RubyTerraform::Commands::Plan)
      .to(receive(:new)
            .and_return(plan))
    allow(plan).to(receive(:execute))
    plan
  end
end
