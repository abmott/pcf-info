#!/usr/bin/env ruby
require 'json'
#require_relative 'params.rb'
require 'aws-sdk-s3'
require 'yaml' #envirnment variables

creds = YAML::load_file('creds.yaml')
wrkdir = Dir.pwd

if not ARGV[0]
  then
  puts ""
  print "Enter Deployment: --> "
    environment = gets.chop
  else environment = ARGV[0]
end

loop do
  case environment
    when 'sandbox', 'pdc', 'gdc'
      break
    else
      puts "Invalid - must enter - pdc, gdc or sandbox"
      puts "Enter Deployment: --> "
      environment = gets.chop
  end
end

environment_url = creds[:"#{environment}"]['opsman_url']
pass = creds[:"#{environment}"]['opsman_password']
opsman_admin = creds[:"#{environment}"]['opsman_admin']

products_list = File.new("#{wrkdir}/#{environment}-stemcell-versions.yml", "w")
target = `uaac target #{environment_url}/uaa`
puts target
connect = `uaac token owner get opsman #{opsman_admin} -p "#{pass}" -s ""`
context = `uaac context`
token = context.split("access_token: ")[1].split("      token_type: bearer")[0]
products = JSON.parse(`curl "#{environment_url}/api/v0/diagnostic_report" -X GET -H "Authorization: Bearer #{token}" -k -s`)
products_list.puts "#{environment.upcase} PCF Deployment Stemcell Information"
products_list.puts ".................."
products['added_products']['deployed'].each do |deployed|
  products_list.puts "Product: #{deployed['name']} Stemcell: #{deployed['stemcell'].split("bosh-stemcell-")[1].split("-go_agent.tgz")[0]}"
end
products_list.puts ".................."
products_list.close

s3 = Aws::S3::Resource.new(
  :access_key_id => creds[:aws]['aws_access_key'],
  :secret_access_key => creds[:aws]['aws_secret_key'],
  :region => 'us-east-1'
)

file = "#{environment}-stemcell-versions.yml"
bucket = 'csaa-pcf-info'

name = File.basename(file)

obj = s3.bucket(bucket).object(name)

obj.upload_file(file)

File.delete("#{wrkdir}/#{environment}-stemcell-versions.yml") if File.exist?("#{wrkdir}/#{environment}-stemcell-versions.yml")
