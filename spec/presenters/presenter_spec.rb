require 'spec_helper'

describe Presenter do
  let(:cat) { 1.hours.ago }
  let(:uat) { Time.now }

  class BasePresenter < Presenter
  end

  describe '.new' do
    it 'should take one argument' do
      expect {
        BasePresenter.new('thing')
      }.not_to raise_error
    end

    it 'should take two arguments' do
      expect {
        BasePresenter.new('thing', option: 'foo')
      }.not_to raise_error
    end

    describe 'the item passed to new' do
      class OtherPresenter < Presenter
      end

      it 'should expose the item as the class name' do
        BasePresenter.new('other').respond_to?(:base).should == true
        OtherPresenter.new('base').respond_to?(:other).should == true
      end

      it 'should return the passed in items' do
        BasePresenter.new('other').base.should == 'other'
        OtherPresenter.new(1_000).other.should == 1_000
      end

      it 'should have the options' do
        BasePresenter.new(nil, option: 'foo').options.should == {:option => 'foo'}
      end
    end
  end

  describe '.many' do
    let(:options) { {:option => 'value'} }
    let(:items) { 2.times.collect {|i| double('item', :id => i.to_s, :created_at => cat, :updated_at => uat, :status => nil) } }

    subject { BasePresenter.many(items, options) }

    it 'should return an array of presenters' do
      subject.collect(&:class).uniq.should == [BasePresenter]
    end

    it 'should be the presenter of the passed items' do
      subject.to_json.should == [
        BasePresenter.new(items.first),
        BasePresenter.new(items.last)
      ].to_json
    end

    it 'should pass the options' do
      subject.map(&:options).uniq.should == [{:option => 'value'}]
    end
  end

  describe '.sub?' do
    it 'should be false' do
      BasePresenter.sub?.should == false
    end
  end

  describe '#as_json' do
    before do
      @item = double('item', :id => 10, :created_at => cat, :updated_at => uat, :other => :value, :string => 'keys', :thing => 2, :something_at => nil, :status => 'foo')
    end

    it 'should be the attributes' do
      json = BasePresenter.new(@item).as_json

      json.should == {
        'id' => '10',
        'created_at' => cat.iso,
        'updated_at' => uat.iso,
        'status' => 'foo'
      }
    end

    describe 'when adding allowed attributes' do
      class RestrictedPresenter < Presenter
        allow :other, :thing, :something_at
      end

      subject { RestrictedPresenter.new(@item) }
      let(:allowed) { [:other, :thing, :something_at] }

      it 'should restrict the attributes' do
        json = subject.as_json

        json.should == {
          'id' => '10',
          'created_at' => cat.iso,
          'updated_at' => uat.iso,
          'status' => 'foo',
          'other' => :value,
          'thing' => 2,
          'something_at' => nil
        }
      end

      it_behaves_like 'a presenter'
    end

    describe 'child presenters' do
      class SubItemPresenter < Presenter
        def self.sub?; true end
        def as_json(*)
          { :custom => 'json'}
        end
      end

      describe 'when adding a sub presenter' do
        class WithSubPresenter < Presenter
          allow :sub_item => SubItemPresenter
          def sub_item?; true end
        end

        subject { WithSubPresenter.new(@item) }

        it 'should have the sub presenters' do
          WithSubPresenter.presenters_attributes.should == { :sub_item => SubItemPresenter }
        end

        it 'should have the sub json' do
          JSON.parse(subject.to_json)['sub_item'].should == { 'custom' => 'json' }
        end

        describe 'when the sub item is not permitted' do
          before do
            subject.stub(:sub_item?).and_return(false)
          end

          it 'should have the sub json' do
            JSON.parse(subject.to_json).should_not have_key('sub_item')
          end
        end
      end

      describe 'when adding a relation presenter (with a sub presenter)' do
        class RelationPresenter < Presenter
          def self.relation?; true end
          def many(items)
            items
          end
        end

        class WithRelationPresenter < Presenter
          allow :items => RelationPresenter, :sub => SubItemPresenter
          def items?; true end; def sub?; true end
        end

        subject { WithRelationPresenter.new(@item) }

        it 'should have the relation/sub presenters' do
          WithRelationPresenter.presenters_attributes.should == { :sub => SubItemPresenter }
          WithRelationPresenter.relations_attributes.should  == { :items => RelationPresenter }
        end

        it 'should have the relation json' do
          @item.stub(:items).and_return([double(:item, :id => '123', :created_at => cat, :updated_at => uat, :status => nil)])
          json = JSON.parse(subject.to_json)

          json['sub'].should == { 'custom' => 'json' }
          json['items'].should == [{'id' => '123', 'created_at' => cat.iso, 'updated_at' => uat.iso, 'status' => nil}]
        end

        describe 'when the relation is not allowed' do
          before do
            subject.stub(:items?).and_return(false)
          end

          it 'should not have the relation json' do
            json = JSON.parse(subject.to_json)

            json.should_not have_key('items')
          end
        end
      end
    end

    describe 'when adding allowed attributes via symbol' do
      class ConditionalPresenter < Presenter
        allow :other, :thing => :admin?
      end

      subject { ConditionalPresenter.new(@item) }
      let(:allowed) { [:other] }

      before do
        subject.stub(:admin?).and_return(false)
      end

      it 'should restrict the attributes' do
        json = subject.as_json

        json.should == {
          'id' => '10',
          'created_at' => cat.iso,
          'updated_at' => uat.iso,
          'status' => 'foo',
          'other' => :value
        }
      end

      it_behaves_like 'a presenter'

      describe 'when the item allows thing' do
        before do
          subject.stub(:admin?).and_return(true)
        end

        it 'should have the allowed keys' do
          json = subject.as_json

          json[:thing].should == 2
        end
      end
    end
  end
end
