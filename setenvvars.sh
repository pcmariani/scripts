#!/usr/bin/env bash

eval $(sqlite3 -header -list -separator ',' environment-vars.db \
    'SELECT * FROM env_vars WHERE org="'"$1"'" AND env="'"$2"'"' |\
    awk -F ',' 'NR==1 { for (i = 4; i <= NF; i++) { f[i]=$i } } \
        NR>1 { for (j = 4;j <= NF; j++) { if (length($j) != 0) \
            { printf "export _%s_%s=\"%s\"\n", $3, f[j], $j } } }')

