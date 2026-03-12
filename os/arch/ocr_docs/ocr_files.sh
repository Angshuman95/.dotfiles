#!/bin/bash

SOURCE_DIR="/home/$USER/Documents/Scans"
ARCHIVE_DIR="/home/$USER/Documents/Archive"

for file in "$SOURCE_DIR"/*.pdf; do
    [ -e "$file" ] || continue

    echo "Processing $(basename "$file")"

    # Keywords
    read -p "Enter keywords (separated by comma): " tags

    # Description
    read -p "Describe file in short: " desc

    new_name="$(date +%Y-%m-%d)_${desc// /_}.pdf"

    # OCR
    ocrmypdf --skip-text "$file" "$ARCHIVE_DIR/$new_name"

    # Tags
    exiftool -overwrite_original -Keywords="$tags" "$ARCHIVE_DIR/$new_name"

    rm "$file"

    echo "Processed $(basename "$file") to $ARCHIVE_DIR/$new_name"
done
