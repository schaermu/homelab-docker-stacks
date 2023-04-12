#!/bin/env bash

# set this variable when calling the script, i.e. WEBHOOK_URL=... ./system-update-notifier.sh
# WEBHOOK_URL="https://discord.com/api/webhooks/..."

# make sure you visudo at least 'apt update *' and 'apt upgrade --simulate' for the crontab user
sudo apt-get update -qqq
COUNTS=$(sudo apt-get upgrade --simulate | grep "not upgraded")
UPDATES=$(sudo apt-get upgrade --simulate | \
	grep Inst | \
	perl -pe 's/Inst (.+) \[.*?([[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+).+\] \(.*?([[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+).*?(?(?=sec)(security.*)|)\[.+\]\)/**\1** from \2 to \3 (\4)/gm' | \
	sed -e 's/()//g;s/\ )/)/g;s/\[\]//g')

if [[ ! -z "$UPDATES" ]]
then
	payload=$(jq -n --arg title "$COUNTS" --arg updates "$UPDATES" '{"username": "system-update-notifier", "content": $title, "embeds": [{"type":"rich","title":"Packages to be upgraded","description": $updates}]}')
	curl -H "Accept: application/json" -H "Content-Type: application/json" -X POST --data "$payload" "$WEBHOOK_URL"
fi
