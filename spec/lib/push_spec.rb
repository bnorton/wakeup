require 'spec_helper'

describe Push do
  let(:user) { double(User, :apn => '1224', :apn? => true) }
  let!(:client) { Urbanairship::Client.new }

  subject { Push.new(user) }

  before do
    Urbanairship::Client.stub(:new).and_return(client)
  end

  describe 'config' do
    [:id, :token, :master].each do |attr|
      it "should have the attr #{attr}" do
        Push.send(attr).should_not be_blank
      end
    end
  end

  describe '.new' do
    it 'should create a client' do
      Urbanairship::Client.should_receive(:new).and_return(client)

      subject
    end

    it 'should add the tokens' do
      client.should_receive(:application_key=).with(described_class.id)
      client.should_receive(:application_secret=).with(described_class.token)
      client.should_receive(:master_secret=).with(described_class.master)

      subject
    end
  end

  describe '#notify' do
    let(:notify) { subject.notify }

    it 'should send a message to the user' do
      client.should_receive(:push).with(hash_including(:device_token => '1224'))

      notify
    end

    it 'should send the alert text' do
      client.should_receive(:push).with(hash_including(:aps =>  { :alert => 'wake yo\' self' }))

      notify
    end

    describe 'when the user does not have a apn' do
      let(:user) { build(:user) }

      it 'should not send the notification' do
        client.should_not_receive(:push)

        notify
      end
    end
  end
end
