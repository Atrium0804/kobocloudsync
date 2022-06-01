# KoboCloudsync
Script for syncing a Kobo device with cloudservices, originaly based on [kobocloud](https://github.com/fsantini/KoboCloud/)

KoboCloudSync uses [rclone](https://rclone.org) to sync a remote share to the kobo device (one way sync).

# Installation
download the `KoboRoot.tgz` file to the (hidden) `.kobo` folder on your device. Eject your device and installation will start.

# Configuration
Shares to be synced are defined in a config file. This file can be created using the `rclone config` command. For detailed instructions, please refer to the [rclone documentation](https://rclone.org/docs/). For password-protected shares, rclone saves an [obscured password](https://rclone.org/commands/rclone_obscure/) in the configuration file.

After creating the the config file, connect your kobo device to your computer and save the file in the (hidden) folder `.adds/kobocloudsync/` on your device.

## Nextcloud Public Shares
Please take notice of the following when using a Nextcloud Public Share link.
When sharing a folder using a public share, nextcloud creates an URL like `https://cloud.yourdomain.com/s/emPBx56rXzKg9HdJXo`. This URL leads to a web page but for syncing rclone needs to approach the webdav service. Append `'public.php/webdav/` to the URL before the `'/s/'` and use the string after the `'s'` as username. For the example URL provided above, this would be:
URL: `https://cloud.yourdomain.com/public.php/webdav`
username: `emPBx56rXzKg9HdJXo`


**Important**: Webdav for public folders should be enabled, see: https://docs.nextcloud.com/server/20/user_manual/en/files/access_webdav.html#accessing-public-shares-over-webdav for more info.