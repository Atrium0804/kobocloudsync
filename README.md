## Installation:
Installation:
- Connect your Kobo device via USB
- Download the KoboRoot.tgz and save it to the (hidden) .kobo folder
- Eject your device
The kobo starts the installation of the software

A configuration file (rclone.conf) is created in .adds/kobocloudsync

## Configuration
The shares to be synced are to be configured in the ./adds/kobocloudsync/rclone.conf file
This file stores the name of the share, the remote location and the credentials used for authentication

The file can be created by the rclone utility. See the [rclone site](https://rclone.org/docs/) for more details and instructions

**Important for Nextcloud users**: Webdav for public folders should be enabled on the nextcloud server, see: https://docs.nextcloud.com/server/20/user_manual/en/files/access_webdav.html#accessing-public-shares-over-webdav for more info.

## Uninstall
For uninstallation of the software, replace the contents of the rclone.conf file with the word 'UNINSTALL' on a single line.
The software will be uninstalled **including** the synced ebooks.
