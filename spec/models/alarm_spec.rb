require 'spec_helper'

describe Alarm do
  describe 'validations' do
    subject { build(:alarm) }

    it { should be_valid }

    validates(:wake_at)
    validates(:user_id)
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:uptime) }
  end
end
