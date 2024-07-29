# frozen_string_literal: true

require 'spec_helper'
require 'logger'

describe RSpec::Terraform::Helpers::Actions::ExecuteIfRequired do
  it 'logs at info when starting to check if execution required' do
    logger = instance_double(Logger)
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::ExecuteIfRequired
    end
    instance = klass.new(logger:)
    parameters = {
      only_if: -> { false }
    }

    allow(logger).to(receive(:info))

    instance.execute_if_required(:action, parameters) do
      # no-op
    end

    expect(logger)
      .to(have_received(:info)
            .with('Checking if execution of action required...'))
  end

  it 'logs at info when execution is required' do
    logger = instance_double(Logger)
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::ExecuteIfRequired
    end
    instance = klass.new(logger:)
    parameters = {
      only_if: -> { true }
    }

    allow(logger).to(receive(:info))

    instance.execute_if_required(:action, parameters) do
      # no-op
    end

    expect(logger)
      .to(have_received(:info)
            .with('Execution required. Continuing...'))
  end

  it 'logs at info when execution is not required' do
    logger = instance_double(Logger)
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::ExecuteIfRequired
    end
    instance = klass.new(logger:)
    parameters = {
      only_if: -> { false }
    }

    allow(logger).to(receive(:info))

    instance.execute_if_required(:action, parameters) do
      # no-op
    end

    expect(logger)
      .to(have_received(:info)
            .with('Execution not required. Skipping...'))
  end

  def stub_rm_rf
    allow(FileUtils).to(receive(:rm_rf))
  end

  def stub_mkdir_p
    allow(FileUtils).to(receive(:mkdir_p))
  end
end
