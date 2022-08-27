# frozen_string_literal: true

require 'spec_helper'
require 'confidante'

describe RSpec::Terraform::Configuration::Providers::Confidante do
  describe '#resolve' do
    context 'when no overrides provided' do
      it 'looks up the specified parameters in confidante' do
        configuration = stub_confidante

        allow(configuration)
          .to(receive(:vars)
                .and_return(first: 1, second: 2))
        allow(configuration)
          .to(receive(:configuration_directory)
                .and_return('path/to/configuration'))

        provider = described_class.new(
          parameters: %i[vars configuration_directory]
        )
        result = provider.resolve

        expect(result)
          .to(eq({
                   vars: { first: 1, second: 2 },
                   configuration_directory: 'path/to/configuration'
                 }))
      end

      it 'does not include parameters that have no value in confidante' do
        configuration = stub_confidante

        allow(configuration).to(receive(:first).and_return(1))
        allow(configuration).to(receive(:second).and_return(nil))

        provider = described_class.new(
          parameters: %i[first second]
        )
        result = provider.resolve

        expect(result).to(eq({ first: 1 }))
      end
    end

    context 'when overrides provided' do
      # rubocop:disable RSpec/VerifiedDoubles
      it 'passes all overrides to confidant as scope and overrides ' \
         'by default' do
        configuration = stub_confidante
        scoped_configuration = double(::Confidante::Configuration)
        overridden_configuration = double(::Confidante::Configuration)

        provider_overrides = {
          first_parameter: 'one',
          second_parameter: 'two'
        }

        allow(configuration)
          .to(receive(:for_scope)
                .with(provider_overrides)
                .and_return(scoped_configuration))
        allow(scoped_configuration)
          .to(receive(:for_overrides)
                .with(provider_overrides)
                .and_return(overridden_configuration))

        allow(overridden_configuration)
          .to(receive(:third_parameter)
                .and_return('three'))

        provider = described_class.new(
          parameters: %i[third_parameter]
        )
        result = provider.resolve(provider_overrides)

        expect(result)
          .to(eq({
                   first_parameter: 'one',
                   second_parameter: 'two',
                   third_parameter: 'three'
                 }))
      end
      # rubocop:enable RSpec/VerifiedDoubles

      # rubocop:disable RSpec/VerifiedDoubles
      it 'uses scope selector to select scope when provided' do
        configuration = stub_confidante
        scoped_configuration = double(::Confidante::Configuration)
        overridden_configuration = double(::Confidante::Configuration)

        provider_overrides = {
          first_parameter: 'one',
          second_parameter: 'two'
        }
        scope = {
          first_parameter: 'one'
        }

        allow(configuration)
          .to(receive(:for_scope)
                .with(scope)
                .and_return(scoped_configuration))
        allow(scoped_configuration)
          .to(receive(:for_overrides)
                .with(provider_overrides)
                .and_return(overridden_configuration))

        allow(overridden_configuration)
          .to(receive(:third_parameter)
                .and_return('three'))

        provider = described_class.new(
          parameters: %i[third_parameter],
          scope_selector: ->(ovrds) { ovrds.slice(:first_parameter) }
        )
        result = provider.resolve(provider_overrides)

        expect(result)
          .to(eq({
                   first_parameter: 'one',
                   second_parameter: 'two',
                   third_parameter: 'three'
                 }))
      end
      # rubocop:enable RSpec/VerifiedDoubles

      # rubocop:disable RSpec/VerifiedDoubles
      it 'uses overrides selector to select overrides when provided' do
        configuration = stub_confidante
        scoped_configuration = double(::Confidante::Configuration)
        overridden_configuration = double(::Confidante::Configuration)

        provider_overrides = {
          first_parameter: 'one',
          second_parameter: 'two'
        }
        configuration_overrides = {
          first_parameter: 'one'
        }

        allow(configuration)
          .to(receive(:for_scope)
                .with(provider_overrides)
                .and_return(scoped_configuration))
        allow(scoped_configuration)
          .to(receive(:for_overrides)
                .with(configuration_overrides)
                .and_return(overridden_configuration))

        allow(overridden_configuration)
          .to(receive(:third_parameter)
                .and_return('three'))

        provider = described_class.new(
          parameters: %i[third_parameter],
          overrides_selector: ->(ovrds) { ovrds.slice(:first_parameter) }
        )
        result = provider.resolve(provider_overrides)

        expect(result)
          .to(eq({
                   first_parameter: 'one',
                   second_parameter: 'two',
                   third_parameter: 'three'
                 }))
      end
      # rubocop:enable RSpec/VerifiedDoubles

      it 'shallow merges non-accumulating configuration parameters ' \
         'by default' do
        configuration = stub_confidante

        allow(configuration).to(receive(:first_parameter).and_return(1))
        allow(configuration).to(receive(:second_parameter).and_return(2))

        overrides = {
          second_parameter: 'two',
          third_parameter: 'three'
        }
        provider = described_class.new(
          parameters: %i[first_parameter second_parameter]
        )
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
         'configuration parameters by default' do
        configuration = stub_confidante

        allow(configuration)
          .to(receive(:vars)
                .and_return(
                  first_var: 1,
                  second_var: 2
                ))
        allow(configuration)
          .to(receive(:var_files)
                .and_return(%w[path/to/file1.tfvars path/to/file2.tfvars]))

        overrides = {
          vars: {
            second_var: 'two',
            third_var: 'three'
          },
          var_files: %w[path/to/file3.tfvars]
        }
        provider = described_class.new(
          parameters: %i[vars var_files]
        )
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

      it 'uses the specified merger when provided' do
        configuration = stub_confidante

        overrides = {
          first: 1,
          second: 2,
          third: 3
        }

        allow(configuration).to(receive(:fourth).and_return(4))

        merger = Object.new
        def merger.merge(left, right)
          left.merge(right.slice(:second))
        end

        provider = described_class.new(
          parameters: %i[fourth],
          merger: merger
        )
        result = provider.resolve(overrides)

        expect(result)
          .to(eq({ second: 2, fourth: 4 }))
      end
    end
  end

  describe '#reset' do
    it 'does nothing' do
      stub_confidante

      provider = described_class.new

      expect { provider.reset }.not_to(raise_error)
    end
  end

  # rubocop:disable RSpec/VerifiedDoubles
  def stub_confidante
    configuration = double(::Confidante::Configuration)
    allow(::Confidante)
      .to(receive(:configuration)
            .and_return(configuration))
    allow(configuration).to(receive(:for_scope).and_return(configuration))
    allow(configuration).to(receive(:for_overrides).and_return(configuration))
    configuration
  end
  # rubocop:enable RSpec/VerifiedDoubles
end
