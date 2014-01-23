require 'spec_helper'

shared_examples_for 'a presenter' do
  it { should be_a(Presenter) }

  describe 'allowed attributes' do
    let(:presenter_name) { subject.class.name.underscore.split('_').map(&:capitalize).join(' ') }
    let(:allowed_keys) { subject.class.allowed_attributes }
    let(:optional_keys) { subject.class.optional_attributes }

    it 'is a presenter' do
      should be_is_a(Presenter)
    end

    it 'is a from presenter' do
      subject.class.ancestors.should include(Presenter)
    end

    it 'sets up the tests correctly' do
      unless respond_to?(:allowed)
        raise StandardError.new(<<-ERROR)
The #{presenter_name} needs to define a set of allowed attributes.

                      describe MyPresenter do
                        let(:allowed) { [:name, :admin] }

                        it_behaves_like 'a presenter'
                      end
        ERROR
      end
    end

    it 'has the right allowed attributes' do
      allowed.each do |attr|
        unless allowed_keys.include?(attr.to_s)
          raise StandardError.new(<<-ERROR)
The #{presenter_name} should allow the '#{attr}' attribute,
              but only allows #{allowed_keys}.
          Try something like this:
              class MyPresenter < Presenter
                allow :#{attr}, ...
              end
          ERROR
        end
      end
    end

    it 'doesn\'t allow extras' do
      allowed_keys = subject.class.allowed_attributes

      if (extra = ((allowed_keys - %w(id created_at updated_at)) - allowed.map(&:to_s))).any?
        raise StandardError.new("The #{presenter_name} allowed extra keys #{extra}")
      end
    end

    it 'has the right optional attributes' do
      if respond_to?(:optional)
        optional.each do |(k, v)|
          unless optional_keys.key?(k)
            raise StandardError.new(<<-ERROR)
The #{presenter_name} should allow the '#{k}' attribute (as an optional),
              but only optionally allows #{optional_keys}.
          Try something like this:
              class MyPresenter < Presenter
                allow :#{k} => :#{v}, ...
              end
            ERROR
          end
        end
      end
    end

    it 'sets up the sub presenters correctly' do
      if respond_to?(:presenters)
        presenters.should be_a(Hash)
      end
    end

    it 'should store the sub presenters correctly' do
      if respond_to?(:presenters)
        subject.class.presenters_attributes.should == presenters
      end
    end

    it 'should require the sub presenters be true for sub?' do
      if respond_to?(:presenters)
        presenters.values.each do |sub|
          raise StandardError, "The given sub presenter #{sub} did not return true for #{sub}.sub?" unless sub.sub?
        end
      end
    end

    it 'presents sub presenters' do
      if respond_to?(:presenters)
        Timecop.freeze(DateTime.now) do
          json = JSON.parse(subject.to_json)

          presenters.each do |(k, v)|
            unless json[k.to_s] == JSON.parse(v.new(model).to_json)
              raise StandardError.new(<<-ERROR)
The #{presenter_name} didn't have the required sub presenters for #{k}.
    Expected: #{json[k.to_s]}
    Got:      #{JSON.parse(v.new(model).to_json)}
          Try something like this:
              class MyPresenter < Presenter
                allow ..., :#{k} => #{v}
              end
              ERROR
            end
          end
        end
      end
    end

    it 'sets up the relation presenters correctly' do
      if respond_to?(:relations)
        relations.should be_a(Hash)
      end
    end

    it 'should store the relation presenters correctly' do
      if respond_to?(:relations)
        subject.class.relations_attributes.should == relations
      end
    end

    it 'should have the related items' do
      if respond_to?(:relations)
        Timecop.freeze(DateTime.now) do
          relations.each do |(k, v)|
            objects = send("#{k}_objects")
            json = JSON.parse(subject.to_json)

            raise StandardError, "Relation presenter #{k} on #{presenter_name} should be an Array but was #{json[k.to_s].class}" unless json[k.to_s].is_a?(Array)

            unless json[k.to_s].sort_by {|j| j['id']} == JSON.parse(v.many(objects).to_json).sort_by {|j| j['id']}
              raise StandardError.new(<<-ERROR)
The #{presenter_name} didn't have the required relation presenters for #{k}.
    Expected: #{json[k.to_s]}
    Got:      #{JSON.parse(v.many(objects).to_json)}
          Try something like this:
              class MyPresenter < Presenter
                allow ..., :#{k} => #{v}
              end
              ERROR
            end
          end
        end
      end
    end
  end
end
