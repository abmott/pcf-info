#!/usr/bin/env ruby
require 'json'
require 'aws-sdk-s3'
require 'date'
require 'time'

wrkdir = Dir.pwd


products_list = File.new("#{wrkdir}/#{ENV['PCF_ENVIRONMENT']}-current_certs.yml", "w")
target = `uaac target #{ENV['OPSMAN_URI']}/uaa --skip-ssl-validation`
connect = `uaac token owner get opsman #{ENV['OPSMAN_USERNAME']} -p "#{ENV['OPSMAN_PASSWORD']}" -s ""`
context = `uaac context`
token = context.split("access_token: ")[1].split("      token_type: bearer")[0]
products = JSON.parse(`curl "#{ENV['OPSMAN_URI']}/api/v0/deployed/certificates?expires_within=2y" -X GET -H "Authorization: Bearer #{token}" -k -s`)
products_list.puts "#{ENV['PCF_ENVIRONMENT'].upcase} PCF Current Certs"
products_list.puts ".................."
products['certificates'].each do |values|
  products_list.print "Issuer: #{values['issuer']} Valid_Until: #{values['valid_until']} Reference: #{values['property_reference']}"
    expire = Time.parse(values['valid_until']).localtime
    expireDays = ((expire - Time.now).to_i / 86400)
      #products_list.puts "Cert expires in #{expireDays}"
        if expireDays < 30
          products_list.puts " Expires_in: #{expireDays}_Days Status: Emergency"
          elsif expireDays < 60
            products_list.puts " Expires_in #{expireDays}_Days Status: Warning"
          elsif expireDays < 90
            print " Expires_in #{expireDays}_Days Status: Caution"
          else
            products_list.puts " Expires_in: #{expireDays}_Days Status: Normal"
        end
end
products_list.puts ".................."
products_list.close

puts ""
File.open("#{wrkdir}/#{ENV['PCF_ENVIRONMENT']}-current_certs.yml").each do |line|
  puts line
end

s3 = Aws::S3::Resource.new(
  :access_key_id => "#{ENV['AWS_ACCESS_KEY']}",
  :secret_access_key => "#{ENV['AWS_SECRET_KEY']}",
  :region => 'us-east-1'
)

file = "#{ENV['PCF_ENVIRONMENT']}-current_certs.yml"
bucket = 'csaa-pcf-info'

name = File.basename(file)

obj = s3.bucket(bucket).object(name)

obj.upload_file(file)

File.delete("#{wrkdir}/#{ENV['PCF_ENVIRONMENT']}-current_certs.yml") if File.exist?("#{wrkdir}/#{ENV['PCF_ENVIRONMENT']}-current_certs.yml")
