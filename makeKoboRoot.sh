#!/bin/sh
rm -f .DS_Store
rm -f KoboRoot.tgz
tar -cvzf KoboRoot.tgz --exclude  '.DS_Store' -C src mnt etc

