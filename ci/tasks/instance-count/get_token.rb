#!/usr/bin/env ruby
require 'json'
require 'yaml'
def get_token(uaa_admin, uaa_pass, url)
    full_token = `curl -v -XPOST -H"Application/json" -u "cf:" --data "username=#{uaa_admin}&password=#{uaa_pass}&client_id=cf&grant_type=password&response_type=token" #{url}`
    new_token = JSON.parse(full_token)
    token = new_token['access_token']
    return token
end
