#!/usr/bin/env ruby
require 'json'
require 'aws-sdk-s3'
require 'yaml'
require 'rubygems'
require 'dogapi'

wrkdir = Dir.pwd
env_name = 'Sandbox'
env_uri = "https://opsmandev.sandbox.gdc.digital.pncie.com"
env_user = "ds-admin"
env_pass = "xiJ4>RwKcgThzXA"

#products_list = File.new("#{wrkdir}/#{env_name}-stemcell-versions.json", "w")
target = `uaac target #{env_uri}/uaa --skip-ssl-validation`
connect = `uaac token owner get opsman #{env_user} -p "#{env_pass}" -s ""`
context = `uaac context`
token = context.split("access_token: ")[1].split("      token_type: bearer")[0]
products = `curl "#{env_uri}/api/v0/diagnostic_report" -X GET -H "Authorization: Bearer #{token}" -k -s`
products_list = JSON.parse(products)
puts "#{products.split("\"added_products\": \{")[1].split("\"staged\":")[0]}"
#products_list["added_products"]["deployed"].each do |deployed|
#  # "#{deployed['name']}"
#  name  = "#{deployed['name']}"
#  # "#{deployed['name']}_#{deployed['stemcell']}"
#  stemcell = "#{deployed['stemcell'].split("bosh-stemcell-")[1].split("-go_agent.tgz")[0]}"
# puts "#{name}, #{stemcell}"
#end

#output_arr = []
#products["added_products"]["deployed"].each do|name|
##puts "#{name}"
#output_arr.push("#{name}")
#end
##puts "_________________"
#puts JSON.pretty_generate(output_arr)
#out_hash = Hash[*output_arr]
#puts output_arr.class
#puts out_hash
#puts out_hash.class
#output_arr["name"].each do |name, stemcell|
#  puts name
#  puts stemcell
#end



#products_list.puts products.to_json
  #Generate Human Readable File
    #products = JSON.parse(`curl "#{ENV['OPSMAN_URI']}/api/v0/diagnostic_report" -X GET -H "Authorization: Bearer #{token}" -k -s`)
    #products_list.puts "#{ENV['PCF_ENVIRONMENT'].upcase} PCF Deployment Stemcell Information"
    #products_list.puts ".................."
    #products['added_products']['deployed'].each do |deployed|
    #  products_list.puts "Product: #{deployed['name']} Stemcell: #{deployed['stemcell'].split("bosh-stemcell-")[1].split("-go_agent.tgz")[0]}"
    #end
    #products_list.puts ".................."
#products_list.close
#
#puts ""
#File.open("#{wrkdir}/#{env_name}-stemcell-versions.json").each do |line|
#  puts line
#end



#s3 = Aws::S3::Resource.new(
#  :access_key_id => "#{ENV['AWS_ACCESS_KEY']}",
#  :secret_access_key => "#{ENV['AWS_SECRET_KEY']}",
#  :region => 'us-east-1'
#)

#file = "#{env_name}-stemcell-versions.json"
#bucket = "#{ENV['S3_BUCKET']}"
#
#name = File.basename(file)
#
#obj = s3.bucket(bucket).object(name)
#
#obj.upload_file(file)

#File.delete("#{wrkdir}/#{env_name}-stemcell-versions.json") if File.exist?("#{wrkdir}/#{env_name}-stemcell-versions.json")
