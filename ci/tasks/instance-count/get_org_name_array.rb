#!/usr/bin/env ruby
require 'json'
require 'yaml'
require_relative 'get_org_info'

def get_org_name_array(organizations)
  name_array = []
  org_info = get_org_info(organizations)
  org_info['resources'].each do |org_array|
    org_array.each do |k, v|
      if k == "entity"
        unless v['name'].include?("system") || v['name'].include?("smoke-test")
          name_array.push("#{v['name']}")
        end
      end
    end
  end
  return name_array
end
