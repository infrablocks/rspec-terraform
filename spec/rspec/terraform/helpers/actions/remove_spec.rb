# frozen_string_literal: true

require 'spec_helper'
require 'logger'

describe RSpec::Terraform::Helpers::Actions::Remove do
  before do
    stub_rm_f
  end

  it 'logs at info level when starting removal' do
    logger = logger_double
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::Remove
    end
    instance = klass.new(logger:)
    file_name = 'thing.tfplan'
    configuration_directory = 'path/to/configuration'
    parameters = {
      configuration_directory:
    }

    instance.remove(parameters, file_name)

    expect(logger)
      .to(have_received(:info)
            .with("Removing file: '#{file_name}' in configuration directory: " \
                  "'#{configuration_directory}'..."))
  end

  it 'logs at info level when completing remove' do
    logger = logger_double
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::Remove
    end
    instance = klass.new(logger:)
    file_name = 'thing.tfplan'
    configuration_directory = 'path/to/configuration'
    parameters = {
      configuration_directory:
    }

    instance.remove(parameters, file_name)

    expect(logger)
      .to(have_received(:info)
            .with('Remove complete.'))
  end

  def logger_double
    logger = instance_double(Logger)
    allow(logger).to(receive(:info))
    allow(logger).to(receive(:debug))
    logger
  end

  def stub_rm_f
    allow(FileUtils).to(receive(:rm_f))
  end
end
