#!/usr/bin/env bash
debug=

# . setenvvars.sh boomi global

post_data()
{
cat <<EOF
{
  "QueryFilter" :
    {
      "expression" :
        {
          "operator" : "and",
          "nestedExpression": [
            {
              "argument" : ["983870bd-3e41-4fcc-a622-c3cb6042d9c2"],
              "operator":"EQUALS",
              "property":"environmentId"
            },
            {
              "argument":["process"],
              "operator":"EQUALS",
              "property":"componentType"
            },
            {
              "argument":[true],
              "operator":"EQUALS",
              "property":"active"
            }
          ]
        }
    }
}
EOF
}

resourcepath="ProcessLog"

[ $debug ] && verbose='-v'

response=$(
curl "$verbose" --location 'https://api.boomi.com/api/rest/v1/aofoundation-W1GLSD/ProcessLog' \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--header 'Authorization: Basic Qk9PTUlfVE9LRU4ucGV0ZXJfbWFyaWFuaUBkZWxsLmNvbToyNWY4YjZjYi05NWI5LTRjYTktOTk2Yy1lZDU5YzgzNjAxM2Q=' \
--data "$(post_data)" \
)

[ $debug ] && printenv | grep '^_[^=]'
[ $debug ] && echo "$(post_data)"

echo "$response" | jq .url | sed 's/"//g'


# curl --location --request POST 'https://api.boomi.com/api/rest/v2/aofoundation-W1GLSD/ProcessLog' \
#     --header 'Content-Type: application/json' \
#     --header 'Accept: application/json' \
#     --header 'Authorization: Basic Qk10PTUlfVE9LRU4ucGV0ZXJfbWFyaWFuaUBkZWxsLmNvbToyNWY4YjZjYi05NWI5LTRjYTktOTk2Yy1lZDU5YzgzNjAxM2Q=' \
#     --data-raw '{"executionId" : "execution-7e9bda43-f3f3-496c-8ab7-b16abeafa203-2020.12.11","logLevel" : "INFO"}' | jq .url | sed 's/"//g'

