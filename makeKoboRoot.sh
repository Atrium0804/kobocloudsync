#!/bin/sh
rm -f .DS_Store
rm -f KoboRoot.tgz
tar -cvzf ~/Nextcloud/Apps/KoboCloudSyncTest/KoboRoot.tgz -C src etc usr
