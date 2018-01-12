#!/usr/bin/env ruby
require 'json'
require 'aws-sdk-s3'

wrkdir = Dir.pwd

products_list = File.new("#{wrkdir}/#{ENV['PCF_ENVIRONMENT']}-deployed_products.json", "w")
target = `uaac target #{ENV['OPSMAN_URI']}/uaa --skip-ssl-validation`
connect = `uaac token owner get opsman #{ENV['OPSMAN_USERNAME']} -p "#{ENV['OPSMAN_PASSWORD']}" -s ""`
context = `uaac context`
token = context.split("access_token: ")[1].split("      token_type: bearer")[0]
products = JSON.parse(`curl "#{ENV['OPSMAN_URI']}/api/v0/deployed/products" -X GET -H "Authorization: Bearer #{token}" -k -s`)
products_list.puts products
  #Generate Human Readable File
    #products = JSON.parse(`curl "#{ENV['OPSMAN_URI']}/api/v0/deployed/products" -X GET -H "Authorization: Bearer #{token}" -k -s`)
    #products_list.puts "#{ENV['PCF_ENVIRONMENT'].upcase} PCF Deployment Deployed Products"
    #products_list.puts ".................."
    #products.each do |values|
    #  products_list.puts "#{values['type']} #{values['product_version']}"
    #end
    #products_list.puts ".................."
products_list.close

puts ""
File.open("#{wrkdir}/#{ENV['PCF_ENVIRONMENT']}-deployed_products.json").each do |line|
  puts line
end


s3 = Aws::S3::Resource.new(
  :access_key_id => "#{ENV['AWS_ACCESS_KEY']}",
  :secret_access_key => "#{ENV['AWS_SECRET_KEY']}",
  :region => 'us-east-1'
)

file = "#{ENV['PCF_ENVIRONMENT']}-deployed_products.json"
bucket = 'csaa-pcf-info'

name = File.basename(file)

obj = s3.bucket(bucket).object(name)

obj.upload_file(file)

File.delete("#{wrkdir}/#{ENV['PCF_ENVIRONMENT']}-deployed_products.json") if File.exist?("#{wrkdir}/#{ENV['PCF_ENVIRONMENT']}-deployed_products.json")
