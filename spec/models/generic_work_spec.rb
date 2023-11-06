# frozen_string_literal: true

require 'spec_helper'
require 'order_already/spec_helper'

RSpec.describe GenericWork do
  subject { described_class.new }

  it { is_expected.to have_already_ordered_attributes(:creator) }
end
