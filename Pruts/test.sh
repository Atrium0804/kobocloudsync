echo '<?xml version="1.0"?>
<a:propfind xmlns:a="DAV:">
<a:prop><a:resourcetype/></a:prop>
</a:propfind>' |
/usr/bin/curl -k --silent -i -X PROPFIND -u w7cr6AZSBGPS6Yn:wrongpassword https://cloud.famstieltjes.nl/public.php/webdav --upload-file - -H Depth: infinity |
grep -Eo '<s:exception>[^<]*[^/]</s:exeption>'