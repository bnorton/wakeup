require 'spec_helper'

describe SessionStartedWorker do
  let(:user) { $user }
  let(:session) { create(:session, :user => user) }

  describe '#perform' do
    let(:perform) { subject.perform(session.id) }

    it 'should touch the user' do
      Timecop.freeze(20.minutes.from_now) do
        perform

        user.reload.updated_at.should be_within(1.second).of(Time.zone.now)
      end
    end

    describe 'when there are active alarms' do
      before do
        @alarm = create(:alarm, :user => user, :wake_at => 1.second.ago, :status => ACTIVE)
      end

      it 'should complete the alarm' do
        perform

        @alarm.reload.status.should == COMPLETED
      end

      it 'should create tomorrows alarm' do
        expect {
          perform
        }.to change(Alarm, :count).by(1)

        alarm = Alarm.last
        alarm.user.should == user
        alarm.wake_at.should be_within(2.seconds).of(1.day.from_now)
      end

      describe 'when the alarm is for the future' do
        before do
          @alarm.update(:wake_at => 1.second.from_now)
        end

        it 'should not complete the alarm' do
          perform

          @alarm.reload.status.should == ACTIVE
        end

        it 'should not add an alarm' do
          expect {
            perform
          }.not_to change(Alarm, :count)
        end
      end
    end

    describe 'when there are started alarms' do
      before do
        @alarm = create(:alarm, :user => user, :wake_at => 1.second.ago, :status => STARTED)
      end

      it 'should complete the alarm' do
        perform

        @alarm.reload.status.should == COMPLETED
      end
    end

    describe 'when there are deleted alarms' do
      before do
        @alarm = create(:alarm, :user => user, :wake_at => 1.second.ago, :status => DELETED)
      end

      it 'should not complete the alarm' do
        perform

        @alarm.reload.status.should == DELETED
      end
    end
  end
end
