require 'spec_helper'

describe UptimePresenter do
  let(:model) { create(:uptime) }
  subject { described_class.new(model) }

  let(:allowed) { [:wake_at] }

  it_behaves_like 'a presenter'
end
