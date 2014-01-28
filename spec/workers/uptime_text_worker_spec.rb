require 'spec_helper'

describe UptimeTextWorker do
  let(:user) { $user }
  let(:uptime) { create(:uptime, :user => user, :texts => 1) }

  describe '#perform' do
    let(:offset) { uptime.offset }
    let!(:messaging) { double(Messaging, :text => nil) }
    let(:perform) { subject.perform(uptime.id, offset) }

    before do
      Messaging.stub(:new).with(user).and_return(messaging)
    end

    it 'should start the uptime' do
      perform

      uptime.reload.status.should == STARTED
    end

    it 'should have the texted attributes' do
      frozen(:perform) do
        uptime.reload.texted_at.should be_within(1).of(Time.zone.now)
        uptime.texts.should == 2
      end
    end

    it 'should send a text message' do
      messaging.should_receive(:text).with('no really wake up')

      perform
    end

    it 'should re-schedule itself' do
      described_class.should_receive(:perform_in).with(30.seconds, uptime.id)

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

      it 'should not send a text message' do
        messaging.should_not_receive(:text)

        perform
      end

      it 'should not re-schedule itself' do
        described_class.should_not_receive(:perform_in)

        perform
      end
    end

    describe 'when the uptime has sent too many texts' do
      before do
        uptime.update(:texts => 2)
      end

      it 'should not send a text message' do
        messaging.should_not_receive(:text)

        perform
      end

      it 'should not update the uptime' do
        perform

        uptime.reload.texts.should == 2
      end

      it 'should not re-schedule itself' do
        described_class.should_not_receive(:perform_in)

        perform
      end
    end

    describe 'when the offset does not match' do
      let(:offset) { 999999 }

      it 'should not send the text message' do
        messaging.should_not_receive(:text)

        perform
      end

      it 'should not re-schedule itself' do
        described_class.should_not_receive(:perform_in)

        perform
      end
    end
  end
end
