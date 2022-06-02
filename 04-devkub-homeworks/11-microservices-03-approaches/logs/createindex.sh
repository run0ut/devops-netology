#!/bin/sh
ret_code=22
http_code=$(curl --silent --output $(mktemp) -X POST http://elastic:qwerty123456@kibana:5601/api/index_patterns/index_pattern \
    -H "kbn-xsrf: true" \
    -H "Content-Type: application/json" \
    -d'
    {
        "override": false,
        "refresh_fields": true,
        "index_pattern": {
            "title":"vector*",
            "timeFieldName":"timestamp"
        }
    }' \
    --write-out "%{http_code}")
if [ "$http_code" == "000" ]; then
    ret_code=22
elif [ "$http_code" != "200" ]; then
    ret_code=${http_code}
else
    ret_code=22
fi
echo $ret_code
exit "$ret_code"