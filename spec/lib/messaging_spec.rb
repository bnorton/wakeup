require 'spec_helper'

describe Messaging do
  let!(:client) { Typhoeus }

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
    let(:user) { create(:user) }
    subject { Messaging.new(user) }

    let(:text) { subject.text('hello you') }

    it 'should send to the sms json endpoint' do
      client.should_receive(:post) do |url,options|
        url.should == 'rest.nexmo.com/sms/json'

        options[:body][:api_key].should == Messaging.id
        options[:body][:api_secret].should == Messaging.token
      end

      text
    end

    it 'should send from us' do
      client.should_receive(:post) do |_,options|
        options[:body][:from].should == Messaging.number
      end

      text
    end

    it 'should send to the user' do
      client.should_receive(:post) do |_,options|
        options[:body][:to].should == user.phone
      end

      text
    end

    it 'should send the given message' do
      client.should_receive(:post) do |_,options|
        options[:body][:text].should == 'hello you'
      end

      text
    end
  end

  describe '#call' do
    let(:user) { create(:user) }
    subject { Messaging.new(user) }

    let(:call) { subject.call('http://example.com/some-callback.json') }

    it 'should send to the sms json endpoint' do
      client.should_receive(:post) do |url,options|
        url.should == 'rest.nexmo.com/tts/json'

        options[:body][:api_key].should == Messaging.id
        options[:body][:api_secret].should == Messaging.token
      end

      call
    end

    it 'should call from us' do
      client.should_receive(:post) do |_,options|
        options[:body][:from].should == Messaging.number
      end

      call
    end

    it 'should call from the user' do
      client.should_receive(:post) do |_,options|
        options[:body][:to].should == user.phone
      end

      call
    end

    it 'should send the wakeup message' do
      client.should_receive(:post) do |_,options|
        options[:body][:text].should == 'wake the fuck up! literally just launch the app'
      end

      call
    end

    it 'should callback to the given url' do
      client.should_receive(:post) do |_,options|
        options[:body][:callback].should == 'http://example.com/some-callback.json'
      end

      call
    end
  end
end
