require 'time'
require 'date'

expire = Time.parse("2018-10-05T03:56:28Z").localtime
expireDays = ((expire - Time.now).to_i / 86400)

if expireDays < 30
  puts "Emergency Expire in #{expireDays} Days"
elsif expireDays < 60
  puts "Warning Expire in #{expireDays} Days"
elsif expireDays < 90
   puts "Caution Expire in #{expireDays} Days"
else
   puts "Expires in #{expireDays} Days"
end

puts seconds_now = Time.now.to_i
