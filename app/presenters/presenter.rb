class Presenter
  def self.inherited(base)
    unless base.respond_to?(:allowed_attributes)
      base.class_attribute(:allowed_attributes)
      base.allowed_attributes = %w(created_at updated_at status)
    end

    unless base.respond_to?(:optional_attributes)
      base.class_attribute(:optional_attributes)
      base.optional_attributes = {}
    end

    unless base.respond_to?(:presenters_attributes)
      base.class_attribute(:presenters_attributes)
      base.presenters_attributes = {}
    end

    unless base.respond_to?(:relations_attributes)
      base.class_attribute(:relations_attributes)
      base.relations_attributes = {}
    end

    base.send(:extend, ClassMethods)
    base.send(:include, InstanceMethods)

    target = "#{base.name.gsub(/Presenter/, '').underscore}"
    define_method target do
      @item
    end
  end

  module InstanceMethods
    def initialize(item, options={})
      @item = item
      @options = options
    end

    def options; @options end

    def as_json(*)
      {}.tap do |json|
        json['id'] = @item.id.to_s

        self.class.allowed_attributes.each do |attr|
          json[attr] = @item.send(attr)
          json[attr] = json[attr].iso if json[attr].respond_to?(:iso)
        end

        self.class.optional_attributes.each do |(k, meth)|
          cond = send(meth)

          json[k] = @item.send(k) if cond
        end

        attach_items!(json)
      end
    end

    def attach_items!(json)
      self.class.presenters_attributes.each do |(sub, v)|
        name = :"#{sub}?"

        (json[sub] = v.new(@item, options).as_json) if respond_to?(name) && send(name)
      end

      self.class.relations_attributes.each do |(relation, v)|
        name = :"#{relation}?"

        json[relation] = v.many(@item.send(relation), options) if respond_to?(name) && send(name)
      end
    end
  end

  module ClassMethods
    def many(items, options={})
      items.collect do |item|
        new(item, options)
      end
    end

    def allow(*args)
      if args.last.is_a?(Hash)
        (options = args.pop).keys.each do |k|
          name = options.delete(k)

          if name.respond_to?(:presenter?)
            if name.sub?
              self.presenters_attributes[k] = name
            else
              self.relations_attributes[k] = name
            end
          else
            self.optional_attributes[k] = name
          end
        end
      end

      self.allowed_attributes = self.allowed_attributes | args.flatten.collect(&:to_s)
    end

    def sub?
      false
    end

    def presenter?
      true
    end
  end
end
