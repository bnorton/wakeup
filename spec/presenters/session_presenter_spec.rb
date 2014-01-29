require 'spec_helper'

describe SessionPresenter do
  let(:model) { create(:session) }
  subject { described_class.new(model) }

  let(:allowed) { [:started_at] }

  it_behaves_like 'a presenter'
end
