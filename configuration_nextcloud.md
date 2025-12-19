# Configure rclone for a Nextcloud Fileshare

Go to the nextcloud folder you want te synchronize
Click on the three dots to open the information panel for the folder
Create an external share and copy the web address

`https://<your_nextcloud_url>/s/<usernameid>`

For configuring the rclone connection use:
- URL: https://<your_nextcloud_url>/public.php/webdav
- username: <username_id>


For example:
- extenral share URL: `https://cloud.mydomain.com/s/abcdef1234567`

If you use the rclone utility to generate a config file:
- connection method: webdav
- url https://<your_nextcloud_url>/public.php/webdav
- vendor: Nextcloud
- username: abcdef1234567
- use the defaults for further configuration

The resulting rclone.conf:
```
[myConnection_name]
type = webdav
url = https://cloud.mydomain.com/public.php/webdav
vendor = nextcloud
user = abcdef1234567