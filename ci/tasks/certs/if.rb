require 'time'
require 'date'

expire = Time.parse("2018-03-05T03:56:28Z").localtime
expireDays = ((expire - Time.now).to_i / 86400)

if expireDays < 30
  puts "Emergency Expire in #{expireDays} Days"
elsif expireDays < 60
  puts "Warning Expire in #{expireDays} Days"
else expireDays < 90
   puts "Caution Expire in #{expireDays} Days"
end
