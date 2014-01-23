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

        it 'should be a 422' do
          response.code.should == '422'
        end

        it 'should not add a user' do
          expect {
            response
          }.not_to change(User, :count)
        end
      end
    end
  end
end
