# frozen_string_literal: true

require 'spec_helper'
require 'logger'

describe RSpec::Terraform::Helpers::Actions::Clean do
  before do
    stub_rm_rf
    stub_mkdir_p
  end

  context 'when execution mode is :in_place' do
    it 'does not log anything' do
      logger = instance_double(Logger)
      klass = Class.new(RSpec::Terraform::Helpers::Base) do
        include RSpec::Terraform::Helpers::Actions::Clean
      end
      instance = klass.new(logger:, execution_mode: :in_place)
      parameters = {
        configuration_directory: 'path/to/configuration'
      }

      allow(logger).to(receive(:info))

      instance.clean(parameters)

      expect(logger).not_to(have_received(:info))
    end
  end

  context 'when execution mode is :isolated' do
    it 'logs when starting to clean configuration directory' do
      logger = instance_double(Logger)
      klass = Class.new(RSpec::Terraform::Helpers::Base) do
        include RSpec::Terraform::Helpers::Actions::Clean
      end
      instance = klass.new(logger:, execution_mode: :isolated)
      configuration_directory = 'path/to/configuration'
      parameters = {
        configuration_directory:
      }

      allow(logger).to(receive(:info))

      instance.clean(parameters)

      expect(logger)
        .to(have_received(:info)
              .with('Cleaning configuration directory: ' \
                    "'#{configuration_directory}'..."))
    end

    it 'logs when completing cleaning of configuration directory' do
      logger = instance_double(Logger)
      klass = Class.new(RSpec::Terraform::Helpers::Base) do
        include RSpec::Terraform::Helpers::Actions::Clean
      end
      instance = klass.new(logger:, execution_mode: :isolated)
      configuration_directory = 'path/to/configuration'
      parameters = {
        configuration_directory:
      }

      allow(logger).to(receive(:info))

      instance.clean(parameters)

      expect(logger)
        .to(have_received(:info)
              .with('Clean complete.'))
    end
  end

  def stub_rm_rf
    allow(FileUtils).to(receive(:rm_rf))
  end

  def stub_mkdir_p
    allow(FileUtils).to(receive(:mkdir_p))
  end
end
