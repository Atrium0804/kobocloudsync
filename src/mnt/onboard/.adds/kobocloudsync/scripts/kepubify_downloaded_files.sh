# 7 process each share: kepubify downloaded files
# process all epub (not: .kepub.epub) files in the document folder for each share
# convert to kepub.epub with kepubify
# generate cover image with covergen
# generate series metadata with seriesmeta
# delete original epub file after successful conversion
echo ""
echo "----------------------------"
echo "Kepubifying downloaded files..."
# Load configuration to get document_folder path
scripts_folder=$(dirname $0)
. $scripts_folder/config.sh

# Fetch rclone shares
. $scripts_folder/prepare_rclone_shares.sh
shares=$(fetch_rclone_shares)


# process each share
shareCount=$(echo "$shares" | wc -l)
shareNum=0
echo "$shares" |
while IFS= read -r currentShare; do
    shareNum=$((shareNum + 1))
    echo ""
    echo "[$shareNum/$shareCount] Processing share: $currentShare"
    shareFolder="$document_folder/$currentShare"
    # find all .epub files (not .kepub.epub) in the share folder
    find "$shareFolder" -type f -name "*.epub" ! -name "*.kepub.epub" |
    while IFS= read -r epubFile; do
        echo "  [KEPUBIFY] Processing file: $epubFile"
        # convert to kepub.epub
        kepubFile="${epubFile%.epub}.kepub.epub"
        $kepubify  --inplace -o "$shareFolder" "$epubFile"
        if [ $? -eq 0 ]; then
            rm -f "$epubFile"
            echo "    [OK] Kepubified and processed: $kepubFile"
        else
            echo "    [ERROR] Failed to kepubify: $epubFile"
        fi
    done
done
