require 'spec_helper'

describe User do
  describe 'validations' do
    subject { build(:user) }

    it { should be_valid }

    validates(:phone)
  end

  describe 'associations' do
    it { should have_one(:uptime) }
  end

  describe '#save' do
    subject { build(:user) }

    describe 'on create' do
      it 'should send a job process the new user' do
        UserWorker.should_receive(:perform_async) do |id|
          id.should == subject.id
        end

        subject.save
      end

      it 'should add a verification code' do
        subject.tap(&:save).code.to_s.should have(4).characters
        subject.vcode.should == nil
      end

      it 'should add an authentication token' do
        subject.tap(&:save).token.should have(24).characters
      end
    end

    describe 'on update' do
      let!(:user) { subject.tap(&:save) }

      it 'should not change the token' do
        token = subject.token

        subject.tap(&:save).reload.token.should == token
      end

      describe 'when adding a vocde' do
        let(:vcode) { subject.code }

        before do
          subject.vcode = vcode
          @token, @code = subject.token, subject.code
        end

        it 'should update the information' do
          subject.tap(&:save).reload

          subject.token.should_not == @token
          subject.code.should_not == @code
          subject.verified_at.should be_within(1).of Time.now
        end

        describe 'when the vcode does not match' do
          let(:vcode) { 'unmatched' }

          it 'should not update the information' do
            subject.tap(&:save).reload

            subject.token.should == @token
            subject.code.should == @code
            subject.verified_at.should == nil
          end
        end
      end
    end
  end
end
