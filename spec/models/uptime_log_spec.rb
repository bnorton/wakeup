require 'spec_helper'

describe UptimeLog do
  describe 'validations' do
    subject { build(:uptime_log) }

    it { should be_valid }

    validates(:offset)
    validates(:pushed_at)
    validates(:texted_at)
    validates(:called_at)
    validates(:pushes)
    validates(:texts)
    validates(:calls)
    validates(:user_id)
    validates(:uptime_id)
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:uptime) }
  end
end
