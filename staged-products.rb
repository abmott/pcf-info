#!/usr/bin/env ruby
require 'json'
require_relative 'params.rb'
require 'aws-sdk-s3'

wrkdir = Dir.pwd

if not ARGV[0]
  then
  puts ""
  print "enter deployment: --> "
    environment = gets.chop
  else environment = ARGV[0]
end

case environment
when "sandbox"
  environment_url = sandbox_env
  pass = sandbox_pass
when "pdc"
  environment_url = pdc_env
  pass = pdc_pass
when "gdc"
  environment_url = gdc_env
  pass = gdc_pass
else
  puts "must enter environment - pdc, gdc or sandbox"
  puts "enter deployment: --> "
  deployment = gets.chop
end

products_list = File.new("#{wrkdir}/#{environment}-staged_products.yml", "w")
target = `uaac target #{environment_url}/uaa`
connect = `uaac token owner get opsman ds-admin -p "#{pass}" -s ""`
context = `uaac context`
token = context.split("access_token: ")[1].split("      token_type: bearer")[0]
products = JSON.parse(`curl "#{environment_url}/api/v0/staged/products" -X GET -H "Authorization: Bearer #{token}" -k -s`)
products_list.puts "#{environment.upcase} PCF Available Products"
products_list.puts ".................."
products.each do |values|
  products_list.puts "#{values['type']} #{values['product_version']}"
end
products_list.puts ".................."

products_list.close

s3 = Aws::S3::Resource.new(
  :access_key_id => aws_access_key,
  :secret_access_key => aws_secret_key,
  :region => 'us-east-1'
)

file = "#{environment}-staged_products.yml"
bucket = 'csaa-pcf-info'

name = File.basename(file)

obj = s3.bucket(bucket).object(name)

obj.upload_file(file)

File.delete("#{wrkdir}/#{environment}-staged_products.yml") if File.exist?("#{wrkdir}/#{environment}-staged_products.yml")
