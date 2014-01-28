require 'spec_helper'

describe SeedWorker do
  describe '#perform' do
    let(:perform) { subject.perform }

    describe 'when there are uptimes' do
      before do
        Timecop.freeze(Time.zone.now.midnight + 1.hour - 1.minute)

        @uptimes = [create(:uptime, :offset => 1.hour+3.minutes),
          create(:uptime, :offset => 2.hours), create(:uptime, :offset => 1.hours, :status => STARTED)]

        UptimePushWorker.stub(:perform_in)
        UptimeTextWorker.stub(:perform_in)
        UptimeCallWorker.stub(:perform_in)
      end

      it 'should send a push job for the matching uptimes' do
        UptimePushWorker.should_receive(:perform_in).with(4.minutes, @uptimes.first.id)

        perform
      end

      it 'should send an text job for the matching uptimes' do
        UptimeTextWorker.should_receive(:perform_in).with(6.minutes, @uptimes.first.id)

        perform
      end

      it 'should send an call job for the matching uptimes' do
        UptimeCallWorker.should_receive(:perform_in).with(8.minutes, @uptimes.first.id)

        perform
      end

      it 'should start the uptime' do
        perform

        @uptimes.first.reload.status.should == QUEUED
      end

      describe 'when the uptimes is active' do
        before do
          @uptimes.last.update(:status => ACTIVE)
        end

        it 'should send a push job for the matching uptimes' do
          UptimePushWorker.should_receive(:perform_in).with(1.minutes, @uptimes.last.id)

          perform
        end

        it 'should send an text job for the matching uptimes' do
          UptimeTextWorker.should_receive(:perform_in).with(3.minutes, @uptimes.last.id)

          perform
        end

        it 'should send an call job for the matching uptimes' do
          UptimeCallWorker.should_receive(:perform_in).with(5.minutes, @uptimes.last.id)

          perform
        end

        it 'should start the uptime' do
          perform

          @uptimes.last.reload.status.should == QUEUED
        end
      end
    end
  end
end
