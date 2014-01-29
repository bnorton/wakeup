require 'spec_helper'

describe AlarmPushWorker do
  let(:user) { $user }
  let(:alarm) { create(:alarm, :user => user, :pushes => 1) }

  describe '#perform' do
    let!(:push) { double(Push, :notify => nil) }
    let(:perform) { subject.perform(alarm.id) }

    before do
      Push.stub(:new).with(user).and_return(push)
    end

    it 'should start the alarm' do
      perform

      alarm.reload.status.should == STARTED
    end

    it 'should have the pushed attributes' do
      frozen(:perform) do
        alarm.reload.pushed_at.should be_within(1.second).of(Time.zone.now)
        alarm.pushes.should == 2
      end
    end

    it 'should send a push notification' do
      push.should_receive(:notify)

      perform
    end

    it 'should re-schedule itself' do
      described_class.should_receive(:perform_in).with(20.seconds, alarm.id)

      perform
    end

    describe 'when the alarm has been started' do
      before do
        alarm.update(:status => STARTED)
      end

      it 'should have the pushed attributes' do
        frozen(:perform) do
          alarm.reload.pushed_at.should be_within(1.second).of(Time.zone.now)
          alarm.pushes.should == 2
        end
      end

      it 'should send a push notification' do
        push.should_receive(:notify)

        perform
      end

      it 'should re-schedule itself' do
        described_class.should_receive(:perform_in).with(20.seconds, alarm.id)

        perform
      end
    end

    describe 'when the alarm has been completed' do
      before do
        alarm.update(:status => COMPLETED)
      end

      it 'should be completed' do
        perform

        alarm.reload.status.should == COMPLETED
      end

      it 'should not send a push notification' do
        push.should_not_receive(:notify)

        perform
      end

      it 'should not re-schedule itself' do
        described_class.should_not_receive(:perform_in)

        perform
      end
    end

    describe 'when the alarm has pushed too many times' do
      before do
        alarm.update(:pushes => 6)
      end

      it 'should not send a push notification' do
        push.should_not_receive(:notify)

        perform
      end

      it 'should not update the alarm' do
        perform

        alarm.reload.pushes.should == 6
      end

      it 'should not re-schedule itself' do
        described_class.should_not_receive(:perform_in)

        perform
      end
    end
  end
end
