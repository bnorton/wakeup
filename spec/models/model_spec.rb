require 'spec_helper'

describe Model do
  subject { build(ActiveRecord::Base.descendants.first.name.underscore) }

  Rails.application.eager_load! && ActiveRecord::Base.descendants.each do |klass|
    it "should be included for #{klass}" do
      klass.ancestors.should include(described_class)
    end
  end

  describe '.belongs_to' do
    it 'should add a belongs to for each' do
      subject.class.send(:belongs_to, :user, :other)

      subject.should respond_to(:user)
      subject.should respond_to(:other)
    end
  end

  describe '#status' do
    it { subject.save; subject.status.should == ACTIVE }

    describe 'when given a different status' do
      before do
        subject.status = DELETED
      end

      it { subject.save; subject.status.should == DELETED }
    end

    describe 'when given an invalid status' do
      before do
        subject.status = 'invalid'
      end

      it { should_not be_valid }
    end
  end

  describe '#slice' do
    before do
      subject.class.send(:attr_accessor, :uid, :foo)

      subject.uid = 5
      subject.foo = 'bar'
    end

    it 'should retrieve the attributes' do
      subject.slice(:foo).should == { :foo => 'bar' }
    end

    it 'should rename attributes' do
      subject.slice(:foo, :uid => :fooid).should == { :fooid => 5, :foo => 'bar' }
    end
  end

  describe '#defaults_before_create' do
    it 'should call on create' do
      subject.should_receive(:defaults_before_create)

      subject.save
    end

    describe 'when the model is saved' do
      before do
        subject.save
      end

      it 'should not call the defaults method' do
        subject.should_not_receive(:defaults_before_create)

        subject.save
      end
    end
  end
end
