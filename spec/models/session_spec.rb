require 'spec_helper'

describe Session do
  describe 'validations' do
    subject { build(:session) }

    it { should be_valid }

    validates(:started_at)
    validates(:user_id)
  end

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe '#save' do
    subject { build(:session) }

    it 'should send a job to process the session' do
      SessionStartedWorker.should_receive(:perform_async) do |id|
        id.should == subject.id
      end

      subject.save!
    end

    describe 'on update' do
      let!(:session) { subject.tap(&:save!) }

      describe 'when ending the session' do
        before do
          subject.ended_at = Time.now
        end

        it 'should complete the session' do
          subject.save!
          subject.status.should == COMPLETED
        end
      end
    end
  end
end
