# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RSpec::Terraform do
  it 'has a version number' do
    expect(RSpec::Terraform::VERSION).not_to be_nil
  end

  it 'adds a terraform_binary setting to RSpec defaulting to "terraform"' do
    expect(RSpec.configuration.terraform_binary).to(eq('terraform'))
  end

  it 'adds a terraform_execution_mode setting to RSpec ' \
     'defaulting to :in_place' do
    expect(RSpec.configuration.terraform_execution_mode).to(eq(:in_place))
  end

  it 'adds a terraform_configuration_provider setting to RSpec' do
    expect(RSpec.configuration.terraform_configuration_provider)
      .to(be_an_instance_of(
            RSpec::Terraform::Configuration::Providers::Identity
          ))
  end

  it 'adds a terraform_log_file_path setting to RSpec' do
    expect { RSpec.configuration.terraform_log_file_path }.not_to(raise_error)
  end

  it 'adds a terraform_log_streams setting to RSpec ' \
     'defaulting to [:standard]' do
    expect(RSpec.configuration.terraform_log_streams).to(eq([:standard]))
  end

  it 'adds a terraform_logger setting to RSpec' do
    expect { RSpec.configuration.terraform_logger }.not_to(raise_error)
  end

  it 'adds a terraform_stdin setting to RSpec' do
    expect { RSpec.configuration.terraform_stdin }.not_to(raise_error)
  end

  it 'adds a terraform_stdout setting to RSpec' do
    expect { RSpec.configuration.terraform_stdout }.not_to(raise_error)
  end

  it 'adds a terraform_stderr setting to RSpec' do
    expect { RSpec.configuration.terraform_stderr }.not_to(raise_error)
  end
end
