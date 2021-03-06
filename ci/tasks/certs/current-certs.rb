#!/usr/bin/env ruby
require 'json'
require 'aws-sdk-s3'
require 'date'
require 'time'

wrkdir = Dir.pwd
datadogprogress = "Pushing Metrics to Datadog"
puts "get List of endpoints from File"
products_list = File.new("#{wrkdir}/#{ENV['PCF_ENVIRONMENT']}-current_certs.yml", "w")
puts "targeting UAAC"
target = `uaac target #{ENV['OPSMAN_URI']}/uaa --skip-ssl-validation`
puts "Connecting to get token"
connect = `uaac token owner get opsman #{ENV['OPSMAN_USERNAME']} -p "#{ENV['OPSMAN_PASSWORD']}" -s ""`
puts "getting context"
context = `uaac context`
puts "pulling token from context"
token = context.split("access_token: ")[1].split("      token_type: bearer")[0]
puts "getting JSON from curl"
products = JSON.parse(`curl "#{ENV['OPSMAN_URI']}/api/v0/deployed/certificates?expires_within=2y" -X GET -H "Authorization: Bearer #{token}" -k -s`)
products_list.puts "#{ENV['PCF_ENVIRONMENT'].upcase} PCF Current Certs"
products_list.puts ".................."
puts "starting to post to Datadog"
products['certificates'].each do |values|
  products_list.print "Issuer: #{values['issuer'].split("/C=US/O=")[1].split("/")[0]} Valid_Until: #{values['valid_until']} Reference: #{values['property_reference']} Product: #{values['product_guid']}"
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
        #curl Metric to DataDog
          printf("\r#{datadogprogress}")
          datadogprogress = datadogprogress.concat(".")
        currenttime = Time.now.to_i
        datadogoutput = `curl -sS -H "Content-type: application/json" -X POST -d \
              '{"series":\
                  [{"metric":"pcf.cert.days_to_expiration}",
                   "points":[[#{currenttime}, #{expireDays}]],
                   "type":"gauge",
                   "host":"#{values['product_guid']}",
                   "tags":["pcf_env:#{ENV['PCF_ENVIRONMENT']}", "name:#{values['property_reference']}", "issuer:#{values['issuer'].split("/C=US/O=")[1].split("/")[0]}"]}]}' \
                   https://app.datadoghq.com/api/v1/series?api_key=#{ENV['DATADOG_API_KEY']}`
        #puts datadogoutput
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
bucket = "#{ENV['S3_BUCKET']}"

name = File.basename(file)

obj = s3.bucket(bucket).object(name)

obj.upload_file(file)

File.delete("#{wrkdir}/#{ENV['PCF_ENVIRONMENT']}-current_certs.yml") if File.exist?("#{wrkdir}/#{ENV['PCF_ENVIRONMENT']}-current_certs.yml")
