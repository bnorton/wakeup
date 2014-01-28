require 'spec_helper'

describe ActiveSupport::TimeZone do
  describe '#offset', :frozen => true do
    subject { Time.zone }

    before do
      Timecop.freeze(Time.zone.now.midnight+6.hours)
    end

    its(:offset) { should == 6*60*60 }
  end
end
