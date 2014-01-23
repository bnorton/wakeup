module Helpers
  def self.included(base)
    base.send(:extend, ClassMethods)
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
end
