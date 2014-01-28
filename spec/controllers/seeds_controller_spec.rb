require 'spec_helper'

describe SeedsController, :redis => true do
  describe '#check' do
    def response
      get :check

      super
    end

    it 'should be a 200' do
      response.code.should == '200'
    end

    it 'should send seed job' do
      SeedWorker.should_receive(:perform_async)

      response
    end

    describe 'when the job has recently been sent' do
      before do
        response

        Timecop.travel(3.minutes)
      end

      it 'should not send a job' do
        SeedWorker.should_not_receive(:perform_async)

        response
      end

      describe 'when the job has recently been sent' do
        before do
          response

          Timecop.travel(1.minutes+1)
        end

        it 'should send seed job' do
          SeedWorker.should_receive(:perform_async)

          response
        end
      end
    end
  end
end
