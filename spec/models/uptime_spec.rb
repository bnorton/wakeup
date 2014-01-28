require 'spec_helper'

describe Uptime do
  describe 'validations' do
    subject { build(:uptime) }

    it { should be_valid }

    validates(:offset)
  end

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe '#save' do
    subject { build(:uptime, :offset => Time.zone.offset-1.minute, :status => DELAYED) }

    describe 'on update' do
      describe 'when modifying the offset' do
        before do
          subject.save!
          subject.offset = subject.offset + 10.minutes
        end

        it 'should activate the uptime' do
          subject.tap(&:save!).reload
          subject.status.should == ACTIVE
        end
      end

      describe 'when completing the uptime' do
        before do
          Timecop.freeze(Time.zone.now)

          subject.save!
          subject.status = COMPLETED
        end

        it 'should send a job to process the completion' do
          UptimeCompletedWorker.should_receive(:perform_async).with(subject.id, subject.offset)

          subject.save!
        end

        describe 'when the time is still in range' do
          before do
            subject.status = DELAYED
            subject.offset += 2.minutes
            subject.save
            subject.status = COMPLETED
          end

          it 'should schedule the job' do
            UptimeCompletedWorker.should_not_receive(:perform_async)
            UptimeCompletedWorker.should_receive(:perform_in).with(10.minutes, subject.id, subject.offset)

            subject.save!
          end
        end
      end
    end
  end
end
