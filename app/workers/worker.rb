class Worker
  ##
  # It is convention to set a @user instance variable in the :perform
  # method of workers. This enables analytics tracking etc.
  #
  def self.inherited(base)
    base.send(:include, InstanceMethods)
    base.send(:include, Sidekiq::Worker)
    base.send(:extend, ClassMethods)

    base.worker :retry => true, :queue => :default
  end

  module ClassMethods
    def worker(options={})
      queue = options[:queue] || options['queue']
      if queue && !%i(low default critical).include?(queue)
        raise ArgumentError, 'queue can be :low, :default, or :critical'
      end

      sidekiq_options options
    end
  end

  module InstanceMethods
  end
end
