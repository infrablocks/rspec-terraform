# frozen_string_literal: true

require 'spec_helper'
require 'logger'

describe RSpec::Terraform::Helpers::Actions::Init do
  before do
    stub_ruby_terraform_init
  end

  it 'logs at info level when starting init' do
    logger = logger_double
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::Init
    end
    instance = klass.new(logger: logger)
    configuration_directory = 'path/to/configuration'
    parameters = {
      configuration_directory: configuration_directory
    }

    instance.init(parameters)

    expect(logger)
      .to(have_received(:info)
            .with('Initing for configuration in directory: ' \
                  "'#{configuration_directory}'..."))
  end

  it 'logs at debug level with all parameters' do
    logger = logger_double
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::Init
    end
    instance = klass.new(logger: logger, execution_mode: :isolated)
    configuration_directory = 'path/to/destination'
    source_directory = 'path/to/source'
    parameters = {
      configuration_directory: configuration_directory,
      source_directory: source_directory
    }

    instance.init(parameters)

    expected_parameters = {
      chdir: configuration_directory,
      input: false,
      from_module: source_directory
    }

    expect(logger)
      .to(have_received(:debug)
            .with("Initing using parameters: #{expected_parameters}..."))
  end

  it 'logs at info level when completing init' do
    logger = logger_double
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::Init
    end
    instance = klass.new(logger: logger)
    configuration_directory = 'path/to/configuration'
    parameters = {
      configuration_directory: configuration_directory
    }

    instance.init(parameters)

    expect(logger)
      .to(have_received(:info)
            .with('Init complete.'))
  end

  def logger_double
    logger = instance_double(Logger)
    allow(logger).to(receive(:info))
    allow(logger).to(receive(:debug))
    logger
  end

  def stub_ruby_terraform_init
    apply = instance_double(RubyTerraform::Commands::Init)
    allow(RubyTerraform::Commands::Init)
      .to(receive(:new)
            .and_return(apply))
    allow(apply).to(receive(:execute))
    apply
  end
end
