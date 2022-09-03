# frozen_string_literal: true

require 'spec_helper'

describe RSpec::Terraform::Logging do
  it 'has resolve_streams method' do
    expect(described_class).to(respond_to(:resolve_streams))
  end
end
