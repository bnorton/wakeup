module Model
  def self.included(base)
    base.send(:extend, ClassMethods)
    base.send(:include, InstanceMethods)

    base.send(:before_create, :process_defaults)
  end

  module ClassMethods
  end

  module InstanceMethods
    def process_defaults
      if respond_to?(:defaults_before_create, true)
        send(:defaults_before_create)
      end
    end
  end
end
