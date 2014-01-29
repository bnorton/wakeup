require 'spec_helper'

describe SeedWorker do
  describe '#perform' do
    let(:perform) { subject.perform }

    describe 'when there are alarms' do
      before do
        Timecop.freeze(Time.zone.now.midnight + 1.hour - 1.minute)

        @alarms = [create(:alarm, :wake_at => Time.zone.now),
          create(:alarm, :wake_at => 6.minutes.from_now), create(:alarm, :wake_at => 30.seconds.ago, :status => STARTED)]

        AlarmPushWorker.stub(:perform_at)
        AlarmTextWorker.stub(:perform_at)
        AlarmCallWorker.stub(:perform_at)
      end

      it 'should send a push job for the matching alarms' do
        AlarmPushWorker.should_receive(:perform_at).with(Time.zone.now, @alarms.first.id)

        perform
      end

      it 'should send an text job for the matching alarms' do
        AlarmTextWorker.should_receive(:perform_at).with(2.minutes.from_now, @alarms.first.id)

        perform
      end

      it 'should send an call job for the matching alarms' do
        AlarmCallWorker.should_receive(:perform_at).with(4.minutes.from_now, @alarms.first.id)

        perform
      end

      it 'should start the alarm' do
        perform

        @alarms.first.reload.status.should == QUEUED
      end

      describe 'when the alarms is active' do
        before do
          @alarms.last.update(:status => ACTIVE)
        end

        it 'should send a push job for the matching alarms' do
          AlarmPushWorker.should_receive(:perform_at).with(30.seconds.ago, @alarms.last.id)

          perform
        end

        it 'should send an text job for the matching alarms' do
          AlarmTextWorker.should_receive(:perform_at).with(1.5.minutes.from_now, @alarms.last.id)

          perform
        end

        it 'should send an call job for the matching alarms' do
          AlarmCallWorker.should_receive(:perform_at).with(3.5.minutes.from_now, @alarms.last.id)

          perform
        end

        it 'should start the alarm' do
          perform

          @alarms.last.reload.status.should == QUEUED
        end
      end
    end
  end
end
