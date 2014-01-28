module Model
  def self.included(base)
    base.send(:extend, ClassMethods)
    base.send(:include, InstanceMethods)

    base.send(:before_validation, :process_defaults_valid)
    base.send(:before_create, :process_defaults_save)
  end

  module ClassMethods
    def belongs_to(*names)
      names.flatten.each {|name| super(name) }
    end
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

    def slice(*args)
      hash = {}

      (args.last.is_a?(Hash) && args.pop || {}).each do |attr, name|
        hash[name] = send(attr)
      end

      args.flatten.each_with_object(hash) do |arg, h|
        h[arg] = send(arg)
      end
    end
  end
end
