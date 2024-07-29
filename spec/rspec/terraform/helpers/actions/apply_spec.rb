# frozen_string_literal: true

require 'spec_helper'
require 'logger'

describe RSpec::Terraform::Helpers::Actions::Apply do
  before do
    stub_ruby_terraform_apply
  end

  it 'logs at info level when starting apply' do
    logger = logger_double
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::Apply
    end
    instance = klass.new(logger:)
    configuration_directory = 'path/to/configuration'
    parameters = {
      configuration_directory:
    }

    instance.apply(parameters)

    expect(logger)
      .to(have_received(:info)
            .with('Applying for configuration in directory: ' \
                  "'#{configuration_directory}'..."))
  end

  it 'logs at debug level with all parameters' do
    logger = logger_double
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::Apply
    end
    instance = klass.new(logger:)
    state_file = 'path/to/state.tfstate'
    configuration_directory = 'path/to/configuration'
    parameters = {
      configuration_directory:,
      state_file:
    }

    instance.apply(parameters)

    expected_parameters = {
      chdir: configuration_directory,
      input: false,
      auto_approve: true,
      state: state_file
    }

    expect(logger)
      .to(have_received(:debug)
            .with("Applying using parameters: #{expected_parameters}..."))
  end

  it 'logs at info level when completing apply' do
    logger = logger_double
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::Apply
    end
    instance = klass.new(logger:)
    configuration_directory = 'path/to/configuration'
    parameters = {
      configuration_directory:
    }

    instance.apply(parameters)

    expect(logger)
      .to(have_received(:info)
            .with('Apply complete.'))
  end

  def logger_double
    logger = instance_double(Logger)
    allow(logger).to(receive(:info))
    allow(logger).to(receive(:debug))
    logger
  end

  def stub_ruby_terraform_apply
    apply = instance_double(RubyTerraform::Commands::Apply)
    allow(RubyTerraform::Commands::Apply)
      .to(receive(:new)
            .and_return(apply))
    allow(apply).to(receive(:execute))
    apply
  end
end
