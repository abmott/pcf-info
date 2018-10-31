
require 'json'
require_relative 'get_token'
require_relative 'get_org_name_array'



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


wrkdir = Dir.pwd
#Create local cert file

access_token = get_token(uaa_admin, uaa_pass, uaa_url)
organizations = `curl "#{pcf_env_url}/v2/organizations" -X GET -H "Authorization: bearer #{access_token}" -k -s`
orgs = get_org_name_array(organizations)
orgs.each do |org|
  puts org
end
