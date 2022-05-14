linkLine='https://cloud.famstieltjes.nl/public.php/webdav/Pwd.pdf'
localFile='/tmp/KoboCloudSync/Documents/PwdFolder/Pwd.pdf'

/usr/bin/curl -u yjCPQpa5m6HaTpN:folderpassword -k -sLI $linkLine | grep -i 'last-modified'
date -r $localFile