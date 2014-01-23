require 'spec_helper'

describe Worker do
  subject { OtherWorker.new }

  class DefaultWorker < Worker
  end

  class OtherWorker < Worker
    worker
  end

  describe 'sidekiq' do
    it 'should be a worker' do
      DefaultWorker.methods.should include(:perform_async)
    end

    it 'should retry' do
      DefaultWorker.get_sidekiq_options['retry'].should == true
    end

    it 'should be default' do
      DefaultWorker.get_sidekiq_options['queue'].should == :default
    end
  end

  %i(low default critical).each do |q|
    describe "for the #{q} queue" do
      before do
        OtherWorker.class_eval { self.worker :queue => q }
      end

      it 'should have the queue' do
        OtherWorker.get_sidekiq_options['queue'].should == q
      end
    end
  end

  it 'should error on invalid queue' do
    expect {
      OtherWorker.class_eval { self.worker :queue => :high }
    }.to raise_error(ArgumentError, 'queue can be :low, :default, or :critical')
  end
end
