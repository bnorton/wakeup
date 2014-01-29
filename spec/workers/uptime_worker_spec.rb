require 'spec_helper'

describe UptimeWorker do
  let(:user) { $user }
  let(:uptime) { create(:uptime, :user => user, :wake_at => Time.now.utc.tomorrow.midnight+1.hour) }

  describe '#perform' do
    let(:perform) { subject.perform(uptime.id) }

    it 'should add an alarm for the wake time' do
      expect {
        perform
      }.to change(Alarm, :count)
    end

    it 'should have the attributes' do
      perform

      alarm = Alarm.last
      alarm.user.should == user
      alarm.wake_at.should == Time.now.utc.tomorrow.midnight+1.hour
    end

    describe 'when there is an existing alarm' do
      before do
        @alarm = create(:alarm, :user => user, :wake_at => 1.hour.from_now)
      end

      it 'should complete the alarm' do
        perform

        @alarm.reload.status.should == COMPLETED
      end

      it 'should still add an alarm for the wake time' do
        expect {
          perform
        }.to change(Alarm, :count)
      end

      it 'should have the attributes' do
        perform

        alarm = Alarm.last
        alarm.user.should == user
        alarm.wake_at.should == Time.now.utc.tomorrow.midnight+1.hour
      end
    end
  end
end
