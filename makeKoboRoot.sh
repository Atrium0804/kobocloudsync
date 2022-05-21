#!/bin/sh
rm -f .DS_Store
rm -f KoboRoot.tgz
tar -cvzf KoboRoot.tgz -C src etc usr mnt
