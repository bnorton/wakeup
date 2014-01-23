require 'spec_helper'

describe Messaging do
  let!(:account) { Twilio::REST::Client.new('a', 'b').account }

  describe 'config' do
    [:id, :token, :number].each do |attr|
      it "should have the attr #{attr}" do
        Messaging.send(attr).should_not be_blank
      end
    end
  end

  describe '.new' do
    it 'requires a phone property' do
      expect {
        Messaging.new('foo')
      }.to raise_error(ArgumentError, 'foo requires a phone number')
    end

    it 'requires a phone number' do
      thing = double(:thing, :phone? => false)

      expect {
        Messaging.new(thing)
      }.to raise_error(ArgumentError, /requires a phone number/)
    end

    it 'allows things with phone numbers' do
      thing = double(:thing, :phone => 'a number')

      expect {
        Messaging.new(thing)
      }.not_to raise_error
    end
  end

  describe '#text' do
    let(:messages) { account.messages }

    let(:user) { create(:user) }
    subject { Messaging.new(user) }

    let(:text) { subject.text('hello you') }

    before do
      Twilio::REST::Client.any_instance.stub(:account).and_return(account)
    end

    it 'should send from us' do
      messages.should_receive(:create).with(hash_including(:from => Messaging.number))

      text
    end

    it 'should send to the user' do
      messages.should_receive(:create).with(hash_including(:to => user.phone))

      text
    end

    it 'should send the given message' do
      messages.should_receive(:create).with(hash_including(:body => 'hello you'))

      text
    end
  end

  describe '#call' do
    let(:calls) { account.calls }

    let(:user) { create(:user) }
    subject { Messaging.new(user) }

    let(:call) { subject.call('http://example.com/some-callback.xml') }

    before do
      Twilio::REST::Client.any_instance.stub(:account).and_return(account)
    end

    it 'should call from us' do
      calls.should_receive(:create).with(hash_including(:from => Messaging.number))

      call
    end

    it 'should call to the user' do
      calls.should_receive(:create).with(hash_including(:to => user.phone))

      call
    end

    it 'should call with a the given' do
      calls.should_receive(:create).with(hash_including(:url => 'http://example.com/some-callback.xml'))

      call
    end

    it 'should GET the url' do
      calls.should_receive(:create).with(hash_including(:method => :get))

      call
    end
  end
end
