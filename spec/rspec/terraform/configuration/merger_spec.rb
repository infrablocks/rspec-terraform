# frozen_string_literal: true

require 'spec_helper'

describe RSpec::Terraform::Configuration::Merger do
  describe '#merge' do
    it 'merges non-accumulating parameters by taking the value ' \
       'from the right' do
      left = {
        first_parameter: 1,
        second_parameter: 2
      }
      right = {
        second_parameter: 'two',
        third_parameter: 'three'
      }
      merger = described_class.new
      merged = merger.merge(left, right)

      expect(merged)
        .to(eq(
              {
                first_parameter: 1,
                second_parameter: 'two',
                third_parameter: 'three'
              }
            ))
    end

    [:vars, :backend_config].each do |map_parameter|
      it "merges accumulating #{map_parameter} map parameter by " \
         'shallow merging left and right' do
        left = {
          map_parameter => {
            first_entry: 1,
            second_entry: 2
          }
        }
        right = {
          map_parameter => {
            second_entry: 'two',
            third_entry: 'three'
          }
        }
        merger = described_class.new
        merged = merger.merge(left, right)

        expect(merged)
          .to(eq(
                {
                  map_parameter => {
                    first_entry: 1,
                    second_entry: 'two',
                    third_entry: 'three'
                  }
                }
              ))
      end
    end

    [:var_files, :targets, :replaces, :plugin_dirs, :platforms]
      .each do |list_parameter|
      it "merges accumulating #{list_parameter} list parameter by " \
         'shallow merging left and right' do
        left = {
          list_parameter => %w[value-1 value-2]
        }
        right = {
          list_parameter => %w[value-3]
        }
        merger = described_class.new
        merged = merger.merge(left, right)

        expect(merged)
          .to(eq(
                {
                  list_parameter => %w[
                    value-1
                    value-2
                    value-3
                  ]
                }
              ))
      end
    end
  end
end
