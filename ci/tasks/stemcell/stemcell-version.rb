#!/usr/bin/env ruby
require 'json'
require 'aws-sdk-s3'
require 'yaml'

wrkdir = Dir.pwd

products_list = File.new("#{wrkdir}/#{ENV['PCF_ENVIRONMENT']}-stemcell-versions.json", "w")
target = `uaac target #{ENV['OPSMAN_URI']}/uaa --skip-ssl-validation`
connect = `uaac token owner get opsman #{ENV['OPSMAN_USERNAME']} -p "#{ENV['OPSMAN_PASSWORD']}" -s ""`
context = `uaac context`
token = context.split("access_token: ")[1].split("      token_type: bearer")[0]
products = `curl "#{ENV['OPSMAN_URI']}/api/v0/diagnostic_report" -X GET -H "Authorization: Bearer #{token}" -k -s`


#output_arr = []
#products["added_products"]["deployed"].each do|name|
#puts "#{name}"
#output_arr.push("#{name}")
#end
#puts "_________________"
products_list.puts products



#products_list.puts products.to_json
  #Generate Human Readable File
    #products = JSON.parse(`curl "#{ENV['OPSMAN_URI']}/api/v0/diagnostic_report" -X GET -H "Authorization: Bearer #{token}" -k -s`)
    #products_list.puts "#{ENV['PCF_ENVIRONMENT'].upcase} PCF Deployment Stemcell Information"
    #products_list.puts ".................."
    #products['added_products']['deployed'].each do |deployed|
    #  products_list.puts "Product: #{deployed['name']} Stemcell: #{deployed['stemcell'].split("bosh-stemcell-")[1].split("-go_agent.tgz")[0]}"
    #end
    #products_list.puts ".................."
products_list.close

puts ""
File.open("#{wrkdir}/#{ENV['PCF_ENVIRONMENT']}-stemcell-versions.json").each do |line|
  puts line
end



s3 = Aws::S3::Resource.new(
  :access_key_id => "#{ENV['AWS_ACCESS_KEY']}",
  :secret_access_key => "#{ENV['AWS_SECRET_KEY']}",
  :region => 'us-east-1'
)

file = "#{ENV['PCF_ENVIRONMENT']}-stemcell-versions.json"
bucket = "#{ENV['S3_BUCKET']}"

name = File.basename(file)

obj = s3.bucket(bucket).object(name)

obj.upload_file(file)

File.delete("#{wrkdir}/#{ENV['PCF_ENVIRONMENT']}-stemcell-versions.json") if File.exist?("#{wrkdir}/#{ENV['PCF_ENVIRONMENT']}-stemcell-versions.json")
