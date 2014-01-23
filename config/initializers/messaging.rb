require 'twilio-ruby'

read_yaml('messaging').slice(:id, :token, :number).each_pair do |k,v|
  Messaging.send("#{k}=", v)
end

# silence_warnings { OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE }
