require 'spec_helper'

describe UserWorker do
  let(:user) { create(:user) }
  let(:messaging) { double(Messaging) }

  describe '#perform' do

    let(:perform) { subject.perform(user.id) }

    before do
      Messaging.stub(:new).with(user).and_return(messaging)
    end

    it 'should send an sms to the user' do
      messaging.should_receive(:text).with("up! #{user.code} verification. enter the code in up! to verify your phone number.")

      perform
    end
  end
end
