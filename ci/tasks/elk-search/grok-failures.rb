#!/usr/bin/env ruby
require 'json'


search_grok = JSON.parse (`curl -XGET "#{ENV['GROK_ENDPOINT']}/_search" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {},
  "version": true,
  "query": {
    "bool": {
      "must": [
        {
          "query_string": {
            "analyze_wildcard": true,
            "query": "*"
          }
        },
        {
          "match_phrase": {
            "tags": {
              "query": "_grokparsefailure"
            }
          }
        },
        {
          "range": {
            "@timestamp": {
              "gt": "now-1w"
            }
          }
        }
      ],
      "must_not": []
    }
  },
  "_source": {
    "excludes": []
  },
  "highlight": {
    "pre_tags": [
      "@kibana-highlighted-field@"
    ],
    "post_tags": [
      "@/kibana-highlighted-field@"
    ],
    "fields": {
      "*": {
        "highlight_query": {
          "bool": {
            "must": [
              {
                "query_string": {
                  "analyze_wildcard": true,
                  "query": "*",
                  "all_fields": true
                }
              },
              {
                "match_phrase": {
                  "tags": {
                    "query": "_grokparsefailure"
                  }
                }
              },
              {
                "range": {
                  "@timestamp": {
                    "gt": "now-1w"
                  }
                }
              }
            ],
            "must_not": []
          }
        }
      }
    },
    "fragment_size": 2147483647
  }
}'`)
#output = `ping 10.91.36.101 -c 4`
puts ".................."
puts search_grok
puts ".................."
#search_grok.each do |values|
  puts search_grok['hits']['total']
#end
puts ".................."
