module Model
  def self.included(base)
    base.send(:extend, ClassMethods)
    base.send(:include, InstanceMethods)

    base.send(:before_validation, :process_defaults_valid)
    base.send(:before_create, :process_defaults_save)
  end

  module ClassMethods
  end

  module InstanceMethods
    def process_defaults_valid
      if respond_to?(:defaults_before_validation, true)
        send(:defaults_before_validation)
      end

      self.status = ACTIVE unless status?
      self.errors.add(:status) unless STATUS.index(status)
    end

    def process_defaults_save
      if respond_to?(:defaults_before_create, true)
        send(:defaults_before_create)
      end
    end
  end
end
