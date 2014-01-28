class Messaging
  cattr_accessor :id, :token, :number

  def initialize(thing)
    raise ArgumentError, "#{thing} requires a phone number" unless thing.respond_to?(:phone)

    @options = {
      :api_key => self.class.id,
      :api_secret => self.class.token,
      :from => self.class.number,
      :to => thing.phone
    }
  end

  def text(message)
    post :sms,
      :text => message
  end

  def call(callback=nil)
    post :tts,
      :text => 'wake the fuck up! literally just launch the app',
      :callback => callback
  end

  private

  def post(name, attrs)
    Typhoeus.post "rest.nexmo.com/#{name}/json", :body => @options.merge(attrs)
  end
end
