#!/bin/bash

COUNT=0
START=$(date +%s)

while read LINE
do
    COUNT=$(($COUNT+1))

    echo "$COUNT"

    if [ $COUNT -gt 10 ] || [ $(($(date +%s) - $START)) -gt 300 ]
    then
        if [ $COUNT -gt 0 ]
        then
            IP="$(grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' <<< "$LINE")"
            echo "$IP hacked us $COUNT times in $(($(date +%s) - $START)) seconds"
            curl -s \
                --form-string "token=autd6v86hdorckvgx9q1mfkvni736n" \
                --form-string "user=uobp8j2x7nipkkconk5b8vgzf2t8f1" \
                --form-string "title=SS Back Home Proxy under Attack." \
                --form-string "message=$IP hacked us $COUNT times in $(($(date +%s) - $START)) seconds." \
                https://api.pushover.net/1/messages.json
            exit
        fi
        break
    fi
done < <(tail -f /var/log/syslog | grep --line-buffered -e ssserver | grep --line-buffered -e WARN)

# */1 * * * * flock -x /tmp/notify_ss.lock -c '/usr/local/bin/notify_ss.sh'