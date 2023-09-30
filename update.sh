#!/bin/env bash

# silence pushd/popd
pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

BLUE=$(tput setaf 4)
RED=$(tput setaf 1)
NORM=$(tput sgr0)

update_all() {
	for dir in */ ; do
		[ -L "${d%/}" ] && continue
		update "$dir"
	done
}

reup_all() {
	for dir in */ ; do
		[ -L "${d%/}" ] && continue
		reup "$dir"
	done
}

update() {
	if [ -d "$1" ]; then
		pushd $1
		echo "${BLUE}[`date`]${NORM} updating '$1'."
        	docker compose pull -q
	        docker compose up -d --force-recreate
		echo "${BLUE}[`date`]${NORM} '$1' updated."
		popd
	else
		echo "${BLUE}[`date`]${RED} '$1' not found!"
	fi
}

reup() {
	if [ -d "$1" ]; then
		pushd $1
		echo "${BLUE}[`date`]${NORM} restarting '$1'."
	        docker compose up -d --force-recreate
		echo "${BLUE}[`date`]${NORM} '$1' restarted."
		popd
	else
		echo "${BLUE}[`date`]${RED} '$1' not found!"
	fi
}

if [ "$#" -ne 2 ]; then
	echo "${BLUE}[`date`]${RED} Please state which action [update/reup] to apply to which stack or use '--all' to apply action to all of them."
        exit
fi

case "$1:$2" in
update:--all) update_all ;;
update:*) update $2 ;;
reup:--all) reup_all ;;
reup:*) reup $2 ;;
esac

# clean up old images after updating
docker image prune -a -f
