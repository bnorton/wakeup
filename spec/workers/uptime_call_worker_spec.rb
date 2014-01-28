require 'spec_helper'

describe UptimeCallWorker do
  let(:user) { $user }
  let(:uptime) { create(:uptime, :user => user, :calls => 1) }

  describe '#perform' do
    let!(:messaging) { double(Messaging, :call => nil) }
    let(:perform) { subject.perform(uptime.id) }

    before do
      Messaging.stub(:new).with(user).and_return(messaging)
    end

    it 'should start the uptime' do
      perform

      uptime.reload.status.should == STARTED
    end

    it 'should have the called attributes' do
      frozen(:perform) do
        uptime.reload.called_at.should be_within(1).of(Time.zone.now)
        uptime.calls.should == 2
      end
    end

    it 'should place a call' do
      messaging.should_receive(:call)

      perform
    end

    it 'should re-schedule itself' do
      UptimeCallWorker.should_receive(:perform_in).with(1.minute, uptime.id)

      perform
    end

    describe 'when the uptime has been completed' do
      before do
        uptime.update(:status => COMPLETED)
      end

      it 'should be completed' do
        perform

        uptime.reload.status.should == COMPLETED
      end

      it 'should not place a call' do
        messaging.should_not_receive(:call)

        perform
      end

      it 'should not re-schedule itself' do
        UptimeCallWorker.should_not_receive(:perform_in)

        perform
      end
    end

    describe 'when the uptime has sent too many calls' do
      before do
        uptime.update(:calls => 4)
      end

      it 'should not place a call' do
        messaging.should_not_receive(:call)

        perform
      end

      it 'should not update the uptime' do
        perform

        uptime.reload.calls.should == 4
      end

      it 'should not re-schedule itself' do
        UptimeCallWorker.should_not_receive(:perform_in)

        perform
      end
    end
  end
end
