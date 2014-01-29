require 'spec_helper'

describe AlarmCallWorker do
  let(:user) { $user }
  let(:alarm) { create(:alarm, :user => user, :calls => 1, :status => STARTED) }

  describe '#perform' do
    let!(:messaging) { double(Messaging, :call => nil) }
    let(:perform) { subject.perform(alarm.id) }

    before do
      Messaging.stub(:new).with(user).and_return(messaging)
    end

    it 'should have the called attributes' do
      frozen(:perform) do
        alarm.reload.called_at.should be_within(1.second).of(Time.zone.now)
        alarm.calls.should == 2
      end
    end

    it 'should place a call' do
      messaging.should_receive(:call)

      perform
    end

    it 'should re-schedule itself' do
      described_class.should_receive(:perform_in).with(1.minute, alarm.id)

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

      it 'should not place a call' do
        messaging.should_not_receive(:call)

        perform
      end

      it 'should not re-schedule itself' do
        described_class.should_not_receive(:perform_in)

        perform
      end
    end

    describe 'when the alarm has sent too many calls' do
      before do
        alarm.update(:calls => 4)
      end

      it 'should not place a call' do
        messaging.should_not_receive(:call)

        perform
      end

      it 'should not update the alarm' do
        perform

        alarm.reload.calls.should == 4
      end

      it 'should not re-schedule itself' do
        described_class.should_not_receive(:perform_in)

        perform
      end
    end
  end
end
