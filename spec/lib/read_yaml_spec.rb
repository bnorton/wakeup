require 'spec_helper'

describe :read_yaml do
  it 'should load the file' do
    read_yaml('messaging.yml')[:number].should be_present
  end

  it 'should add the extension' do
    read_yaml('messaging')[:number].should be_present
  end

  it 'should read a the current rails env' do
    dev = read_yaml('messaging')[:number]

    Rails.stub(:env).and_return('production')
    read_yaml('messaging')[:number].should be_present

    read_yaml('messaging')[:number].should_not == dev
  end

  describe 'when the file is not found' do
    it 'should error (config load error)' do
      expect {
        read_yaml 'blah'
      }.to raise_error(StandardError, /blah/)
    end
  end
end
