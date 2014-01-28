class Push
  cattr_accessor :id, :token, :master

  def initialize(user)
    @user = user
    @client = Urbanairship::Client.new.tap do |u|
      u.application_key = self.class.id
      u.application_secret = self.class.token
      u.master_secret = self.class.master
    end
  end

  def notify
    @client.push(
      :device_token => @user.apn,
      :aps => { :alert => 'wake yo\' self' }
    ) if @user.apn?
  end
end
