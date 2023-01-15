#!/usr/bin/env bash
included_volumes="tools_vaultwarden-data streaming_jellyfin-data smarthome_zigbee2mqtt-data security_crowdsec-data"

function exists_in_list() {
    LIST=$1
    DELIMITER=$2
    VALUE=$3
    [[ "$LIST" =~ ($DELIMITER|^)$VALUE($DELIMITER|$) ]]
}

function mount_volumes {
	volumes=$(docker volume ls --format '{{.Name}}')
	for volume in $volumes
	do
	        if !(exists_in_list "$included_volumes" " " $volume); then
	                continue
	        fi

	        # determine source and target folders for volume
	        printf "[%s] backing up volume $volume\n" "$(date)"
	        source=$(docker volume inspect --format '{{.Mountpoint}}' "$volume")
	        mount_path=/mnt/docker-volume-backups/$volume

	        sudo mkdir -p $mount_path
	        sudo mount --bind -o ro $source $mount_path

	        # pause associated containers to prevent data corruption during backup
	        containers=$(docker ps -a -f volume=$volume --format '{{.ID}}')
	        for cont in $containers
	        do
	                docker pause $cont
	        done
	done
}

function unmount_volumes {
	volumes=$(docker volume ls --format '{{.Name}}')
	for volume in $volumes
	do
		if !(exists_in_list "$included_volumes" " " $volume); then
                        continue
                fi

	        # determine source and mount folders for volume
	        source=$(docker volume inspect --format '{{.Mountpoint}}' "$volume")
	        mount_path=/mnt/docker-volume-backups/$volume

		sudo umount $mount_path
                sudo rm $mount_path -rf

	        # resume associated containers
	        containers=$(docker ps -a -f volume=$volume --format '{{.ID}}')
	        for cont in $containers
	        do
	                docker unpause $cont
	        done
	done
}

if [ "$#" -ne 1 ]; then
        echo "Please tell me to either mount or unmount."
        exit
fi

case $1 in
        "mount") mount_volumes ;;
        "unmount") unmount_volumes ;;
        *) echo "Please tell me to either mount or unmount." ;;
esac
