require 'spec_helper'

describe UsersController do
  describe '.create' do
    let(:options) { { :phone => '7143005444', :timezone => '-5', :locale => 'DE', :version => '1.2', :udid => '123', :bundle => 'com.blah' } }

    describe '.json' do
      def response
        xhr :post, :create, options.merge( :format => 'json' )

        super
      end

      it 'should be a 201' do
        response.code.should == '201'
      end

      it 'should add a user' do
        expect {
          response
        }.to change(User, :count).by(1)
      end

      it 'should have the attributes' do
        response

        user = User.last
        user.phone.should == '7143005444'
        user.timezone.should == -5
        user.locale.should == 'DE'
        user.version.should == '1.2'
        user.udid.should == '123'
        user.bundle.should == 'com.blah'
        user.verified_at.should == nil
      end

      it 'should return the new user' do
        response.body.should == UserPresenter.new(User.last).to_json
      end

      describe 'when a user exists with a phone number' do
        before do
          create(:user, options)
        end

        it 'should be a 404' do
          response.code.should == '404'
        end

        it 'should not add a user' do
          expect {
            response
          }.not_to change(User, :count)
        end
      end
    end
  end

  describe '#update' do
    let(:user) { create(:user) }
    let(:options) { { :vcode => vcode, :version => '1.2.4', :locale => 'GB', :timezone => '-2', :status => 'deleted' } }

    describe '.json' do
      let(:vcode) { user.code }

      def response
        xhr :put, :update, options.merge( :id => user.id, :format => 'json' )

        super
      end

      it 'should be a 200' do
        response.code.should == '200'
      end

      it 'should update the vcode' do
        user.vcode.should == nil

        response

        user.reload.vcode.should == vcode
      end

      it 'should have the new attributes' do
        response

        user.reload
        user.timezone.should == -2
        user.locale.should == 'GB'
        user.version.should == '1.2.4'
        user.status.should == 'deleted'
      end

      describe 'when the code does not match' do
        let(:vcode) { 'not-match' }

        it 'should be a 422' do
          response.code.should == '422'
        end
      end
    end
  end
end
