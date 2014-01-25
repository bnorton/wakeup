require 'spec_helper'

describe Uptime do
  describe 'validations' do
    subject { build(:uptime) }

    it { should be_valid }

    validates(:offset)
  end

  describe 'associations' do
    it { should belong_to(:user) }
  end
end
