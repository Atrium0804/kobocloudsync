# Debugging Synchronisation Issues

# log files
Log files are written to:
- ` KOBOeReader/.adds/kobocloudsync
  - kobocloudsync.log
  - rclone.log

# Enabling SSH-access
SSH-Acces can be enabled:
- connect your kobo to a computer
- navigate to ` KOBOeReaser/.kobo/` 
- rename the file `ssh-disabled` to `ssh-enabled`
- Reboot the device
- Connect via: ssh root@<device_ip>

# running kobocloudsync on the device
For debugging, you kan access the device via SSH and run the kobocloudsync in the SSH-session:
`./mnt/onboard/.adds/kobocloudsync/opt/udev_program.sh`
