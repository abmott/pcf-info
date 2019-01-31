#!/usr/bin/env ruby

require 'csv'
require 'json'
require 'open3'

def csv_to_array(file_location)
    csv = CSV::parse(File.open(file_location, 'r') {|f| f.read })
    fields = csv.shift
    fields = fields.map {|f| f.downcase.gsub(" ", "")}
    csv.collect { |record| Hash[*fields.zip(record).flatten ] }
end


wrkdir = Dir.pwd
var_file = File.read("#{wrkdir}/params-local.json")
vars_values = JSON.parse(var_file)
vars_values.keys.each do |env|
  #if env == "sandbox"
    pcf_env_url = vars_values["#{env}"]['pcf_env_url']
    admin = vars_values["#{env}"]['opsman_admin']
    opsman_pass = vars_values["#{env}"]['opsman_pass']
    datadog_api = vars_values["#{env}"]['datadog_api_key']
    pcf_admin_user = vars_values["#{env}"]['pcf_admin_user']
    pcf_admin_user_pass = vars_values["#{env}"]['pcf_admin_user_pass']

    stdout, stderr, status = Open3.capture3("cf login -a #{pcf_env_url} -o ds -u #{pcf_admin_user} -p '#{pcf_admin_user_pass}' -s none")
    puts stdout
    puts stderr
    puts status
    puts "getting usage for #{pcf_env_url}"
    usage_file = `cf usage-report -f csv > usage.csv`
    puts "*******************"
  #end

output = csv_to_array("usage.csv")
org_names = []
output.each do |usage_array|
  usage_array.each do |k, v|
    if k == "orgname"
      org_names.push(v)
  end
  end
end
org_names = org_names.uniq
org_names = org_names.compact

org_names.each do |org|
  puts org
#  puts "********"
end

total_ai_running = 0
total_ai_deployed = 0
total_apps_running = 0
total_apps_deployed = 0
total_orgs = 0
org_names.each do |org|
  unless org.to_s.strip.empty?
  total_orgs = total_orgs + 1
  output.each do |usage_array|
    if usage_array['orgname'] == org
      if usage_array['appsrunning'].to_i > 0
        puts org
        puts "#{usage_array['spacename'].gsub(/\s+/, '')}"
        puts "Memory used #{usage_array['spacememoryused']} MB"
        #curl Metric to DataDog
  #      puts "posting to datadog"
  #     currenttime = Time.now.to_i
  #     datadogoutput = `curl -sS -H "Content-type: application/json" -X POST -d \
  #           '{"series":\
  #              [{"metric":"test.pcf.app_space_memory_used}",
  #                "points":[[#{currenttime}, #{usage_array['spacememoryused']}]],
  #                "type":"gauge",
  #                "host":"#{org}",
  #                "tags":["pcf_env:#{env}", "org:#{org}", "space:#{usage_array['spacename']}"]}]}' \
  #                https://app.datadoghq.com/api/v1/series?api_key=#{datadog_api}`
        #puts datadogoutput
        puts "AI's Deployed #{usage_array['appinstancesdeployed']}"
        #curl Metric to DataDog
  #      puts "posting to datadog"
  #     currenttime = Time.now.to_i
  #     datadogoutput = `curl -sS -H "Content-type: application/json" -X POST -d \
  #           '{"series":\
  #              [{"metric":"test.pcf.app_instance_deployed}",
  #                "points":[[#{currenttime}, #{usage_array['appinstancesdeployed']}]],
  #                "type":"gauge",
  #                "host":"#{org}",
  #                "tags":["pcf_env:#{env}", "org:#{org}", "space:#{usage_array['spacename']}"]}]}' \
  #                https://app.datadoghq.com/api/v1/series?api_key=#{datadog_api}`
        #puts datadogoutput
        puts "AI's running #{usage_array['appinstancesrunning']}"
        #curl Metric to DataDog
  #      puts "posting to datadog"
  #     currenttime = Time.now.to_i
  #     datadogoutput = `curl -sS -H "Content-type: application/json" -X POST -d \
  #           '{"series":\
  #              [{"metric":"test.pcf.app_instance_running}",
  #                "points":[[#{currenttime}, #{usage_array['appinstancesrunning']}]],
  #                "type":"gauge",
  #                "host":"#{org}",
  #                "tags":["pcf_env:#{env}", "org:#{org}", "space:#{usage_array['spacename']}"]}]}' \
  #                https://app.datadoghq.com/api/v1/series?api_key=#{datadog_api}`
        #puts datadogoutput
        puts "Apps's running #{usage_array['appsrunning']}"
        #curl Metric to DataDog
  #      puts "posting to datadog"
  #     currenttime = Time.now.to_i
  #     datadogoutput = `curl -sS -H "Content-type: application/json" -X POST -d \
  #           '{"series":\
  #              [{"metric":"test.pcf.app_instance_running}",
  #                "points":[[#{currenttime}, #{usage_array['appsrunning']}]],
  #                "type":"gauge",
  #                "host":"#{org}",
  #                "tags":["pcf_env:#{env}", "org:#{org}", "space:#{usage_array['spacename']}"]}]}' \
  #                https://app.datadoghq.com/api/v1/series?api_key=#{datadog_api}`
        #puts datadogoutput
        puts "Apps's deployed #{usage_array['appsdeployed']}"
        #curl Metric to DataDog
  #      puts "posting to datadog"
  #     currenttime = Time.now.to_i
  #     datadogoutput = `curl -sS -H "Content-type: application/json" -X POST -d \
  #           '{"series":\
  #              [{"metric":"test.pcf.app_instance_deployed}",
  #                "points":[[#{currenttime}, #{usage_array['appsdeployed']}]],
  #                "type":"gauge",
  #                "host":"#{org}",
  #                "tags":["pcf_env:#{env}", "org:#{org}", "space:#{usage_array['spacename']}"]}]}' \
  #                https://app.datadoghq.com/api/v1/series?api_key=#{datadog_api}`
        #puts datadogoutput
        puts "*************************"
        total_ai_running = usage_array['appinstancesrunning'].to_i + total_ai_running
        total_ai_deployed = usage_array['appinstancesdeployed'].to_i + total_ai_deployed
        total_apps_running = usage_array['appsrunning'].to_i + total_apps_running
        total_apps_deployed = usage_array['appsdeployed'].to_i + total_apps_deployed

      end
    end
  end
end
end
puts "total orgs = #{total_orgs}"
puts "total ai running = #{total_ai_running}"
puts "total ai deployed = #{total_ai_deployed}"
puts "total apps running #{total_apps_running}"
puts "total apps running #{total_apps_deployed}"
end
