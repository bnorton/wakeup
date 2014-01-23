require 'spec_helper'

describe UserPresenter do
  let(:model) { create(:user) }
  subject { described_class.new(model) }

  let(:allowed) { [:phone, :token, :locale, :version, :timezone] }

  it_behaves_like 'a presenter'
end
