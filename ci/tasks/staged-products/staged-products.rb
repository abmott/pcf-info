#!/usr/bin/env ruby
require 'json'
require 'aws-sdk-s3'

wrkdir = Dir.pwd

products_list = File.new("#{wrkdir}/#{ENV['PCF_ENVIRONMENT']}-staged_products.yml", "w")
target = `uaac target #{ENV['OPSMAN_URI']}/uaa`
connect = `uaac token owner get opsman #{ENV['OPSMAN_USERNAME']} -p "#{ENV['OPSMAN_PASSWORD']}" -s ""`
context = `uaac context`
token = context.split("access_token: ")[1].split("      token_type: bearer")[0]
products = JSON.parse(`curl "#{ENV['OPSMAN_URI']}/api/v0/staged/products" -X GET -H "Authorization: Bearer #{token}" -k -s`)
products_list.puts "#{ENV['PCF_ENVIRONMENT'].upcase} PCF Available Products"
products_list.puts ".................."
products.each do |values|
  products_list.puts "#{values['type']} #{values['product_version']}"
end
products_list.puts ".................."

products_list.close

s3 = Aws::S3::Resource.new(
  :access_key_id => "#{ENV['AWS_ACCESS_KEY']}",
  :secret_access_key => "#{ENV['AWS_SECRET_KEY']}",
  :region => 'us-east-1'
)

file = "#{ENV['PCF_ENVIRONMENT']}-staged_products.yml"
bucket = 'csaa-pcf-info'

name = File.basename(file)

obj = s3.bucket(bucket).object(name)

obj.upload_file(file)

File.delete("#{wrkdir}/#{ENV['PCF_ENVIRONMENT']}-staged_products.yml") if File.exist?("#{wrkdir}/#{ENV['PCF_ENVIRONMENT']}-staged_products.yml")
