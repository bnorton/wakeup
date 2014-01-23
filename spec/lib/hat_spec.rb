require 'spec_helper'

describe Hat do
  describe '.sixtwo_s' do
    let(:sixtwo_s) { Hat.sixtwo_s(@number) }

    [[0,'0'],[100,'1C'],[4000,'12w'],[123456789,'8m0Kx']].each do |(from, to)|
      it "should go from(int): #{from} to(string): #{to}" do
        @number = from

        from.should be_a(Numeric)
        to.should be_a(String)

        sixtwo_s.should == to
      end
    end
  end

  describe '.sixtwo_i' do
    let(:sixtwo_i) { Hat.sixtwo_i(@string) }

    [[0,'0'],[100,'1C'],[4000,'12w'],[123456789,'8m0Kx'],[805021499,'StMRJ']].each do |(to, from)|
      it "should go from(string): #{from} to(int): #{to}" do
        @string = from

        from.should be_a(String)
        to.should be_a(Numeric)

        sixtwo_i.should == to
      end
    end
  end

  describe '.short' do
    it 'should generate a string' do
      described_class.short.should be_a(String)
    end

    it 'should generate 10 character short code' do
      10_000.times.map { described_class.short.length }.uniq.should == [10]
    end
  end

  describe '.long' do
    it 'should generate a string' do
      described_class.long.should be_a(String)
    end

    it 'should generate 24 character short code' do
      10_000.times.map { described_class.long.length }.uniq.should == [24]
    end
  end
end
