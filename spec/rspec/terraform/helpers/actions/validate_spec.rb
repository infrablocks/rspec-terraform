# frozen_string_literal: true

require 'spec_helper'
require 'logger'

describe RSpec::Terraform::Helpers::Actions::Validate do
  it 'logs at info level when starting validate' do
    logger = logger_double
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::Validate

      def required_parameters(_)
        %i[first second]
      end
    end
    instance = klass.new(logger:)
    parameters = {
      first: 'one',
      second: 'two'
    }

    instance.validate(parameters)

    expect(logger)
      .to(have_received(:info)
            .with('Validating required parameters: ' \
                  '[:first, :second] present...'))
  end

  it 'logs at debug level with all parameters' do
    logger = logger_double
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::Validate

      def required_parameters(_)
        %i[first second]
      end
    end
    instance = klass.new(logger:)
    parameters = {
      first: 'one',
      second: 'two'
    }

    instance.validate(parameters)

    expect(logger)
      .to(have_received(:debug)
            .with("Validating parameters: #{parameters}..."))
  end

  it 'logs at info level when validation is successful' do
    logger = logger_double
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::Validate

      def required_parameters(_)
        %i[first second]
      end
    end
    instance = klass.new(logger:)
    parameters = {
      first: 'one',
      second: 'two'
    }

    instance.validate(parameters)

    expect(logger)
      .to(have_received(:info)
            .with('Validate successful.'))
  end

  it 'logs at error level when validation is unsuccessful' do
    logger = logger_double
    klass = Class.new(RSpec::Terraform::Helpers::Base) do
      include RSpec::Terraform::Helpers::Actions::Validate

      def required_parameters(_)
        %i[first second third]
      end
    end
    instance = klass.new(logger:)
    parameters = {
      first: 'one',
      fourth: 'four'
    }

    begin
      instance.validate(parameters)
    rescue StandardError
      # expected
    end

    expect(logger)
      .to(have_received(:error)
            .with(
              'Validate failed. Parameters: [:second, :third] missing.'
            ))
  end

  def logger_double
    logger = instance_double(Logger)
    allow(logger).to(receive(:error))
    allow(logger).to(receive(:info))
    allow(logger).to(receive(:debug))
    logger
  end

  def stub_ruby_terraform_show
    show = instance_double(RubyTerraform::Commands::Validate)
    allow(RubyTerraform::Commands::Validate)
      .to(receive(:new)
            .and_return(show))
    allow(show).to(receive(:execute))
    show
  end
end
