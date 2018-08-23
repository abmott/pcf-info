#!/usr/bin/env ruby
require 'json'
require 'yaml'

def get_org_guid(url)
  guid = "#{url.split("/v2/organizations/")[1].split("/spaces")[0]}"
  return guid
end
