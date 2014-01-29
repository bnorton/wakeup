require 'spec_helper'

describe Uptime do
  describe 'validations' do
    subject { build(:uptime) }

    it { should be_valid }

    validates(:wake_at)
    validates(:user_id)
  end

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe '#save' do
    subject { build(:uptime) }

    it 'should send a job to process the item' do
      UptimeWorker.should_receive(:perform_async) do |id|
        id.should == subject.id
      end

      subject.save!
    end

    describe 'on update' do
      let!(:uptime) { subject.tap(&:save!) }

      describe 'when modifying the wake time' do
        subject { build(:uptime, :wake_at => Time.zone.now, :status => DELETED) }

        before do
          subject.wake_at = 1.day.from_now
        end

        it 'should activate the uptime' do
          subject.tap(&:save!).reload
          subject.status.should == ACTIVE
        end

        it 'should send a job to process the item' do
          UptimeWorker.should_receive(:perform_async).with(subject.id)

          subject.save!
        end
      end
    end
  end
end
