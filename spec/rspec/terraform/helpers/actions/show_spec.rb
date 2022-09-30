# frozen_string_literal: true

require 'spec_helper'
require 'logger'

describe RSpec::Terraform::Helpers::Actions::Show do
  before do
    stub_ruby_terraform_show
  end

  it 'logs at info level when starting show' do
    logger = logger_double
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::Show
    end
    instance = klass.new(logger: logger)
    configuration_directory = 'path/to/configuration'
    file_name = 'thing.tfplan'
    parameters = {
      configuration_directory: configuration_directory
    }

    instance.show(parameters, file_name)

    expect(logger)
      .to(have_received(:info)
            .with("Showing file: '#{file_name}' in configuration directory: " \
                  "'#{configuration_directory}'..."))
  end

  it 'logs at debug level with all parameters' do
    logger = logger_double
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::Show
    end
    instance = klass.new(logger: logger)
    file_name = 'thing.tfplan'
    configuration_directory = 'path/to/configuration'
    parameters = {
      configuration_directory: configuration_directory
    }

    instance.show(parameters, file_name)

    expected_parameters = {
      chdir: configuration_directory,
      no_color: true,
      json: true,
      path: file_name
    }

    expect(logger)
      .to(have_received(:debug)
            .with("Showing using parameters: #{expected_parameters}..."))
  end

  it 'logs at info level when completing show' do
    logger = logger_double
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::Show
    end
    instance = klass.new(logger: logger)
    configuration_directory = 'path/to/configuration'
    file_name = 'thing.tfplan'
    parameters = {
      configuration_directory: configuration_directory
    }

    instance.show(parameters, file_name)
    expect(logger)
      .to(have_received(:info)
            .with('Show complete.'))
  end

  def logger_double
    logger = instance_double(Logger)
    allow(logger).to(receive(:info))
    allow(logger).to(receive(:debug))
    logger
  end

  def stub_ruby_terraform_show
    show = instance_double(RubyTerraform::Commands::Show)
    allow(RubyTerraform::Commands::Show)
      .to(receive(:new)
            .and_return(show))
    allow(show).to(receive(:execute))
    show
  end
end
