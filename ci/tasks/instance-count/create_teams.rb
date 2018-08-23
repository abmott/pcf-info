#!/usr/bin/env ruby
require 'json'
require_relative 'get_token'
require_relative 'get_org_name_array'
require_relative 'get_space_url_info'
require_relative 'get_space_name_and_guid'
require_relative 'create_team_method'
require_relative 'connect_to_concourse'
#require_relative 'create_teams_method'

uaa_admin = "#{ENV['UAA_ADMIN']}"
uaa_pass = "#{ENV['UAA_PASS']}"
uaa_url = "#{ENV['UAA_URL']}"
pcf_env_url = "#{ENV['PCF_ENV_URL']}"
c_env = "#{ENV['CONCOURSE_ENV']}"
c_user = "#{ENV['CONCOURSE_ADMIN']}"
c_pass = "#{ENV['CONCOURSE_PASS']}"
c_url = "#{ENV['CONCOURSE_URL']}"
client_id = "#{ENV['CLIENT_ID']}"
client_secret = "#{ENV['CLIENT_SECRET']}"
auth_url = "#{ENV['AUTH_URL']}"
token_url = "#{ENV['TOKEN_URL']}"
cf_url = "#{ENV['CF_URL']}"
cert = "#{ENV['WILDCARD_CERT']}"
team_blacklist = "#{ENV['TEAM_BLACKLIST']}".split(', ')

wrkdir = Dir.pwd
#Create local cert file
File.write("#{wrkdir}/wildcard.cer", "#{cert}")
connect_to_concourse(c_env, c_user, c_pass, c_url)
access_token = get_token(uaa_admin, uaa_pass, uaa_url)
organizations = `curl "#{pcf_env_url}/v2/organizations" -X GET -H "Authorization: bearer #{access_token}" -k -s`
orgs = get_org_name_array(organizations)
orgs.each do |org|
  puts "*******************************************"
  puts "creating teams for #{org.upcase}"
  puts "*******************************************"

  #spaces = `curl "#{pcf_env_url}/#{get_space_url_info(organizations, org)}?results-per-page=100" -X GET -H "Authorization: bearer #{access_token}" -k -s`
  space_url = get_space_url_info(organizations, org)
  #puts space_url
  space_guid = get_space_name_and_guid(pcf_env_url, space_url, access_token)
  #remove blacklist spaces from space_guid hash
  team_blacklist.each do |blacklist|
    space_guid.each do |space, guid|
      space = space.to_s
      if space.include? "#{blacklist}"
        space_guid.tap { |h| h.delete(:"#{space}")}
      end
    end
  end
  #Create spaces with dev, Dev and DEV
  space_guid.each do |space, guid|
    space = space.to_s
    if space.include?("dev") || space.include?("DEV") || space.include?("Dev")
      puts "make team"
      puts "#{space}"
      puts "#{guid}"
      create_team("#{space}", "#{guid}", "#{c_env}", "#{client_id}", "#{client_secret}", "#{auth_url}", "#{token_url}", "#{cf_url}")
    end
  end
end

File.delete("#{wrkdir}/wildcard.cer") if File.exist?("#{wrkdir}/wildcard.cer")
