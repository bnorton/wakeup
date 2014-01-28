require 'spec_helper'

describe UptimeCompletedWorker do
  let(:user) { $user }
  let(:uptime) { create(:uptime, :user => user, :status => COMPLETED) }

  describe '#perform' do
    let(:perform) { subject.perform(uptime.id) }

    before do
      uptime.update(
        :pushes => 2, :texts => 3, :calls => 1,
        :pushed_at => Time.at(1), :texted_at => Time.at(2), :called_at => Time.at(3)
      )
    end

    it 'should mark the uptime as active' do
      perform

      uptime.reload.status.should == ACTIVE
    end

    it 'should log the values' do
      expect {
        perform
      }.to change(UptimeLog, :count).by(1)
    end

    it 'should have the previous values' do
      perform

      log = UptimeLog.last
      log.slice(:user, :uptime, :offset).values.should == [user, uptime, uptime.offset]
      log.slice(:pushes, :texts, :calls).values.should == [2,3,1]
      log.slice(:pushed_at, :texted_at, :called_at).values.should == [Time.at(1),Time.at(2),Time.at(3)]
    end

    describe 'when the uptime is not completed' do
      before do
        uptime.update(:status => DELAYED)
      end

      it 'should ignore the work' do
        expect {
          perform
        }.not_to change(UptimeLog, :count)

        uptime.reload.status.should == DELAYED
      end
    end
  end
end
