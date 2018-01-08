#!/usr/bin/env ruby
require 'json'


#output = `curl \"https://www.google.com\"`
output = `curl \"http://10.91.36.101:9200\"`
#output = `ping 10.91.36.101 -c 4`
puts output
