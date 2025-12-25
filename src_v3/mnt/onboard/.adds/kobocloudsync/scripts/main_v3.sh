# 1 Load the configuration which sets paths to binaries

# 2 check start conditions (dependencies, rclone config file, network)

# 3 from rclone config file, process each remote share:
#   - create a target folder for the share if it doesn't exist
#   - create an empty local metadata file if it doesn't exist
#   - list files in the share and download remote metadata
#   - update local metadata file: remove entries for files that no longer exist remotely
#     - donot remove metadata if kepubified files exist locally
#     - remove metadata if neither original nor kepubified file exists locally
#   - local deletions: if a file was deleted or change remotely, delete it locally
#           - delete the kepubified version if it exists
#           - delete the original file if it exists
#   - downloads remote files: if a file exists remotely but not locally, download it
#   - process downloaded files with kepubify
#     - if a .epub-files exits:
#        - convert to .kepub.epub with kepubify
#        - generate cover image with covergen
#        - generate series metadata with seriesmeta
#        - delete original .epub file