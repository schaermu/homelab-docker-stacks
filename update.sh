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

update() {
	if [ -d "$1" ]; then
		pushd $1
		echo "${BLUE}[`date`]${NORM} updating '$1'."
        	docker compose pull -q
	        docker compose up -d
		echo "${BLUE}[`date`]${NORM} '$1' updated."
		popd
	else
		echo "${BLUE}[`date`]${RED} '$1' not found!"
	fi
}


if [ "$#" -ne 1 ]; then
	echo "${BLUE}[`date`]${RED} Please state which stack to update or use '--all' to patch them all."
        exit
fi

case $1 in
        "--all") update_all ;;
        *) update $1 ;;
esac

# clean up old images after updating
docker image prune -a -f
