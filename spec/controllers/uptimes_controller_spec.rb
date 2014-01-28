require 'spec_helper'

describe UptimesController do
  let(:user) { $user }

  describe '.create' do
    let(:options) { { :offset => 3.hours.to_i } }

    describe '.json' do
      def response
        xhr :post, :create, options.merge( :user_id => user.id, :format => 'json' )

        super
      end

      it 'should be a 201' do
        response.code.should == '201'
      end

      it 'should add a uptime' do
        expect {
          response
        }.to change(Uptime, :count).by(1)
      end

      it 'should have the attributes' do
        response

        uptime = Uptime.last
        uptime.user.should == user
        uptime.offset.should == 3*60*60 # 3 hours in seconds
      end

      it 'should return the new uptime' do
        response.body.should == UptimePresenter.new(Uptime.last).to_json
      end
    end
  end

  describe '#update' do
    let!(:uptime) { create(:uptime, :user => user, :offset => (Time.zone.now - Time.zone.now.midnight)+10) }
    let(:options) { { :offset => 23.hours+59.minutes+59.seconds, :status => 'completed' } }

    describe '.json' do
      def response
        xhr :put, :update, options.merge( :user_id => user.id, :format => 'json' )

        super
      end

      it 'should be a 200' do
        response.code.should == '200'
      end

      it 'should have the new attributes' do
        response

        uptime.reload
        uptime.offset.should == (23*60*60)+(59*60)+59
        uptime.status.should == 'completed'
      end
    end
  end
end
