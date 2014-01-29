require 'spec_helper'

describe AlarmTextWorker do
  let(:user) { $user }
  let(:alarm) { create(:alarm, :user => user, :texts => 1, :status => STARTED) }

  describe '#perform' do
    let!(:messaging) { double(Messaging, :text => nil) }
    let(:perform) { subject.perform(alarm.id) }

    before do
      Messaging.stub(:new).with(user).and_return(messaging)
    end

    it 'should have the texted attributes' do
      frozen(:perform) do
        alarm.reload.texted_at.should be_within(1.second).of(Time.zone.now)
        alarm.texts.should == 2
      end
    end

    it 'should send a text message' do
      messaging.should_receive(:text).with('no really wake up')

      perform
    end

    it 'should re-schedule itself' do
      described_class.should_receive(:perform_in).with(30.seconds, alarm.id)

      perform
    end

    describe 'when the alarm has been completed' do
      before do
        alarm.update(:status => COMPLETED)
      end

      it 'should be completed' do
        perform

        alarm.reload.status.should == COMPLETED
      end

      it 'should not send a text message' do
        messaging.should_not_receive(:text)

        perform
      end

      it 'should not re-schedule itself' do
        described_class.should_not_receive(:perform_in)

        perform
      end
    end

    describe 'when the alarm has sent too many texts' do
      before do
        alarm.update(:texts => 2)
      end

      it 'should not send a text message' do
        messaging.should_not_receive(:text)

        perform
      end

      it 'should not update the alarm' do
        perform

        alarm.reload.texts.should == 2
      end

      it 'should not re-schedule itself' do
        described_class.should_not_receive(:perform_in)

        perform
      end
    end
  end
end
