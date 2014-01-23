require 'spec_helper'

describe UserPresenter do
  let(:model) { create(:user) }
  subject { described_class.new(model) }

  let(:allowed) { [:phone, :udid, :token, :locale, :version, :timezone, :bundle] }

  it_behaves_like 'a presenter'
end
