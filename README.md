## Description
Kobocloudsync syncs documents from cloudservices to your kobodevice.
The syncing is based on rclone which supports many cloudservices (Nextcloud, Dropbox, Onedrive, WebDAV etc). 
Kobocloudsync is tested with Nextcloud.

## Prerequisites
Kobocloudsync uses NickelMenu to provide a menu item for starting the sync.
Please refer to https://pgaskin.net/NickelMenu/ for installation

## Installation:
Installation:
- Connect your Kobo device via USB
- Download the KoboRoot.tgz and save it to the (hidden) .kobo folder
- Eject your device
The kobo starts the installation of the software

A configuration file (rclone.conf) is created in .adds/kobocloudsync.

The sync is started from home screen using the 'Cloudsync' entry in the NickelMenu.

## Configuration
The shares to be synced are to be configured in the `./adds/kobocloudsync/rclone.conf` file
This file stores the name of the share, the remote location and the credentials used for authentication

The file can be created by the rclone utility. See the [rclone site](https://rclone.org/docs/) for more details and instructions

Start the rclone configuration and specify the output location for the config file, eg:

`./rclone config --config="rclone.conf"`

**Important for Nextcloud users**:
Select the WebDav option when configuring rclone.
For host use the URL like: `https://example.com/nextcloud/public.php/webdav`
Webdav for public folders should be enabled on the nextcloud server, see: https://docs.nextcloud.com/server/20/user_manual/en/files/access_webdav.html#accessing-public-shares-over-webdav for more info.

## Usage
After installation and configuration, a Cloudsync menu-entry is shown in the NickelMenu-menu. This menu-entry starts the syncing of the configured cloud shares and refreshes the book list.

## Uninstall
Uninstall is done by connecting the Kobo device via USB and:
- delete the hidden folder .adds/kobocloudsync
- remove the file .adds/nm/kobocloudsync
