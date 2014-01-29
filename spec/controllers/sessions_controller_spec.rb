require 'spec_helper'

describe SessionsController do
  let(:user) { $user }

  describe '.create' do
    let(:options) { { :started_at => 5.seconds.ago } }

    describe '.json' do
      def response
        xhr :post, :create, options.merge( :user_id => user.id, :format => 'json' )

        super
      end

      it 'should be a 201' do
        response.code.should == '201'
      end

      it 'should add a session' do
        expect {
          response
        }.to change(Session, :count).by(1)
      end

      it 'should have the attributes' do
        response

        session = Session.last
        session.user.should == user
        session.started_at.should be_within(1.second).of(5.seconds.ago)
        session.status.should == ACTIVE
      end

      it 'should return the new session' do
        response.body.should == SessionPresenter.new(Session.last).to_json
      end
    end
  end

  describe '#update' do
    let!(:session) { create(:session, :user => user) }
    let(:options) { { :ended_at => Time.zone.now } }

    describe '.json' do
      def response
        xhr :put, :update, options.merge( :user_id => user.id, :id => session.id, :format => 'json' )

        super
      end

      it 'should be a 200' do
        response.code.should == '200'
      end

      it 'should have session end time' do
        response

        session.reload
        session.ended_at.should be_within(1.second).of(Time.zone.now)
        session.status.should == COMPLETED
      end

      it 'should return the session' do
        response.body.should == SessionPresenter.new(session.reload).to_json
      end
    end
  end
end
