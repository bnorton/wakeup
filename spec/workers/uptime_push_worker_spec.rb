require 'spec_helper'

describe UptimePushWorker do
  let(:user) { $user }
  let(:uptime) { create(:uptime, :user => user, :pushes => 1) }

  describe '#perform' do
    let(:offset) { uptime.offset }
    let!(:push) { double(Push, :notify => nil) }
    let(:perform) { subject.perform(uptime.id, offset) }

    before do
      Push.stub(:new).with(user).and_return(push)
    end

    it 'should start the uptime' do
      perform

      uptime.reload.status.should == STARTED
    end

    it 'should have the pushed attributes' do
      frozen(:perform) do
        uptime.reload.pushed_at.should be_within(1).of(Time.zone.now)
        uptime.pushes.should == 2
      end
    end

    it 'should send a push notification' do
      push.should_receive(:notify)

      perform
    end

    it 'should re-schedule itself' do
      described_class.should_receive(:perform_in).with(20.seconds, uptime.id)

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

      it 'should not send a push notification' do
        push.should_not_receive(:notify)

        perform
      end

      it 'should not re-schedule itself' do
        described_class.should_not_receive(:perform_in)

        perform
      end
    end

    describe 'when the uptime has pushed too many times' do
      before do
        uptime.update(:pushes => 6)
      end

      it 'should not send a push notification' do
        push.should_not_receive(:notify)

        perform
      end

      it 'should not update the uptime' do
        perform

        uptime.reload.pushes.should == 6
      end

      it 'should not re-schedule itself' do
        described_class.should_not_receive(:perform_in)

        perform
      end
    end

    describe 'when the offset does not match' do
      let(:offset) { 999999 }

      it 'should not send a push notification' do
        push.should_not_receive(:notify)

        perform
      end

      it 'should not re-schedule itself' do
        described_class.should_not_receive(:perform_in)

        perform
      end
    end
  end
end
