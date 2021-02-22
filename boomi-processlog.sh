#!/usr/bin/env bash
debug=

# . setenvvars.sh boomi global

post_data()
{
cat <<EOF
{
    "executionId" : "execution-6e6fcc3a-7964-4197-8d90-666459b584bf-2021.02.01",
    "logLevel" : "INFO"
}
EOF
}

resourcepath="ProcessLog"

[ $debug ] && verbose='-v'

response=$(
curl "$verbose" --silent --location 'https://api.boomi.com/api/rest/v1/aofoundation-W1GLSD/ProcessLog' \
--user "$_aapi_username:$_aapi_password" \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--data "$(post_data)" \
)

[ $debug ] && printenv | grep '^_[^=]'
[ $debug ] && echo "$(post_data)"

url=$(
echo $response | jq -r '.url'
)

filename=$(
echo $url | sed 's/^.*\///'
)
filename+=".zip"

sleep 4

# echo "$url"

logzipfile=$(
curl --silent --location "$url" \
--user "$_aapi_username:$_aapi_password" \
-o "$filename"
)

processname=$(
echo $(unzip -c "$filename" | head -3 | tail +3 | sed -e 's/^.*Executing Process //' -e 's/ /_/g' -e 's/\r//')
)
# echo "$processname"

mv "$filename" "${processname}_${filename}"
