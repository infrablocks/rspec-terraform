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
end
