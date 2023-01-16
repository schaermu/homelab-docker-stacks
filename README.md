# System Overview
![System Overview](system-overview.png)
There are some special aspects in this setup:
* In order for `homeassistant` to be able to expose an Apple HomeKit Bridge, an additional network interface has to be added (see below). This ensures traffic can be routed directly to HomeAssistant **WITHOUT** it running in `network_mode: host`.
* Several cronjobs are set up to sync the mergerfs array's parity using SnapRaid and to scrub the ZFS pool on a regular basis.
* Because i want to access several services from the internet (Grafana, Photoprism, Jellyseerr), a cronjob updates the Route53 DNS record with the external IP every 30 minutes.
# Maintenance
## Updating
The repository is configured to update all docker compose stacks using [Renovate](https://github.com/renovatebot/renovate) on a regular basis. After renovate's pull-requests have been merged, you can simply pull in the changes on your server using `git pull` and update either all stacks using `./update.sh --all` or a specific stack by executing `./update.sh [stack_name]`.

This script also cleans up old and unused images after restarting the stacks to make sure no disk space is wasted.

## Backing up
For runtime application data, the stacks use Docker volumes. There is a helper script called `backup-volumes.sh` which helps you integrate a proper and safe way to backup all docker volumes. If you want to set it up yourself, make sure you properly edit the included volumes on line 2 (`included_volumes`).

The script can be called with 2 arguments, `mount` and `unmount`:
* `mount` will read-only mount all included volumes to `/mnt/docker-volume-backups/[VOLUME]` and pause all containers using said volume.
* `unmount` reverses the above process by unmounting the volume, removing the mount point and resuming the paused containers.

So before triggering the actual backup using the backup tool of your choice, you have to call the script with `mount`, after the backup is done you should call `unmount`. Personally, i'm using [Borgmatic](https://torsion.org/borgmatic/) using its `before_everything` and `after_everything` hooks.