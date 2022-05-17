#!/bin/sh
rm -f .DS_Store
rm -f KoboRoot.tgz
tar -cvzf /Volumes/KOBOeReader/.kobo/KoboRoot.tgz -C src etc usr
