class Messaging
  cattr_accessor :id, :token, :number

  def initialize(thing)
    raise ArgumentError, "#{thing} requires a phone number" unless thing.respond_to?(:phone)

    @account = Twilio::REST::Client.new(self.class.id, self.class.token).account
    @thing   = thing
  end

  def text(message)
    @account.messages.create(
      :from => self.class.number,
      :to => @thing.phone,
      :body => message
    )
  end

  def call(url)
    @account.calls.create(
      :from => self.class.number,
      :to => @thing.phone,
      :method => :get,
      :url => url
    )
  end
end
