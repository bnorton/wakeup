require 'spec_helper'

describe UserPresenter do
  let(:model) { create(:user) }
  subject { described_class.new(model) }

  let(:allowed) { [:phone, :udid, :token, :locale, :version, :timezone, :bundle, :verified_at] }

  it_behaves_like 'a presenter'
end
