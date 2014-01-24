module Helpers
  METHODS = %i(get post put delete)

  def self.included(base)
    base.send(:extend, ClassMethods)
    base.send(:include, InstanceMethods)

    METHODS.each do |type|
      base.alias_method_chain(type, :headers) rescue nil
    end
  end

  module ClassMethods
    def validates(name)
      it "should return a #{name}" do
        subject.send("#{name}=", nil)
        should_not be_valid
        should have(1).error_on(name)
      end
    end
  end

  module InstanceMethods
    METHODS.each do |type|
      define_method :"#{type}_with_headers" do |path, *args|
        options = args.shift || {}
        headers = args.shift || {}

        token = respond_to?(:user) ? user.token : nil
        controller.request.stub(:headers).and_return({'X-User-Token' => token}.merge(headers))

        send(:"#{type}_without_headers", path, options)
      end
    end
  end
end
