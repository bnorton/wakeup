require 'spec_helper'

describe UptimesController do
  let(:user) { $user }
  let(:wake) { '2014-10-31T10:20:40.679Z' }

  describe '.create' do
    let(:options) { { :wake_at => wake } }

    describe '.json' do
      def response
        xhr :post, :create, options.merge( :user_id => user.id, :format => 'json' )

        super
      end

      it 'should be a 201' do
        response.code.should == '201'
      end

      it 'should add an uptime' do
        expect {
          response
        }.to change(Uptime, :count).by(1)
      end

      it 'should have the attributes' do
        response

        uptime = Uptime.last
        uptime.user.should == user
        uptime.wake_at.should == Time.parse(wake)
      end

      it 'should return the new uptime' do
        response.body.should == UptimePresenter.new(Uptime.last).to_json
      end
    end
  end

  describe '#update' do
    let!(:uptime) { create(:uptime, :user => user, :wake_at => Time.zone.now, :status => DELETED) }
    let(:options) { { :wake_at => wake } }

    describe '.json' do
      def response
        xhr :put, :update, options.merge( :user_id => user.id, :format => 'json' )

        super
      end

      it 'should be a 200' do
        response.code.should == '200'
      end

      it 'should have the new wake time' do
        response

        uptime.reload
        uptime.wake_at.should == Time.parse(wake)
        uptime.status.should == 'active'
      end

      it 'should return the uptime' do
        response.body.should == UptimePresenter.new(uptime.reload).to_json
      end
    end
  end
end
