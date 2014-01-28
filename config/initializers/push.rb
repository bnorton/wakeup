read_yaml('push').each_pair do |k,v|
  Push.send("#{k}=", v)
end
