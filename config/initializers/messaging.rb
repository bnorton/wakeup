require 'twilio-ruby'

read_yaml('messaging').slice(:id, :token, :number).each_pair do |k,v|
  Messaging.send("#{k}=", v)
end
