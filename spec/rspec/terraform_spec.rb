# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RSpec::Terraform do
  it 'has a version number' do
    expect(RSpec::Terraform::VERSION).not_to be_nil
  end
end
