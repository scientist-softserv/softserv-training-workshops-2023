# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Image`
require 'order_already/spec_helper'

RSpec.describe Image do
  subject { described_class.new }

  it { is_expected.to have_already_ordered_attributes(:creator) }

  describe 'indexer' do
    subject { described_class.indexer }

    it { is_expected.to eq ImageIndexer }
  end
end
