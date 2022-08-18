# frozen_string_literal: true

require 'spec_helper'

describe RSpec::Terraform::Configuration::Providers::InMemory do
  describe '#resolve' do
    context 'when no overrides provided' do
      it 'returns the in memory configuration when no overrides provided' do
        configuration = {
          first_parameter: 1,
          second_parameter: 2
        }
        provider = described_class.new(configuration)

        expect(provider.resolve).to(eq(configuration))
      end
    end

    context 'when overrides provided' do
      it 'shallow merges non-accumulating configuration parameters' do
        configuration = {
          first_parameter: 1,
          second_parameter: 2
        }
        overrides = {
          second_parameter: 'two',
          third_parameter: 'three'
        }
        provider = described_class.new(configuration)
        result = provider.resolve(overrides)

        expect(result)
          .to(eq(
                {
                  first_parameter: 1,
                  second_parameter: 'two',
                  third_parameter: 'three'
                }
              ))
      end

      it 'accumulates by shallow merging accumulating ' \
         'configuration parameters' do
        configuration = {
          vars: {
            first_var: 1,
            second_var: 2
          },
          var_files: %w[path/to/file1.tfvars path/to/file2.tfvars]
        }
        overrides = {
          vars: {
            second_var: 'two',
            third_var: 'three'
          },
          var_files: %w[path/to/file3.tfvars]
        }
        provider = described_class.new(configuration)
        result = provider.resolve(overrides)

        expect(result)
          .to(eq(
                {
                  vars: {
                    first_var: 1,
                    second_var: 'two',
                    third_var: 'three'
                  },
                  var_files: %w[
                    path/to/file1.tfvars
                    path/to/file2.tfvars
                    path/to/file3.tfvars
                  ]
                }
              ))
      end
    end
  end
end
