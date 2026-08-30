#!/bin/bash

SOURCE_DIR="/home/$USER/Documents/scans"
ARCHIVE_DIR="/home/$USER/Documents/syncthing/archive"

for file in "$SOURCE_DIR"/*.pdf; do
    [ -e "$file" ] || continue

    echo "Processing $(basename "$file")"

    # Keywords
    read -p "Enter keywords (separated by comma): " tags

    # Description
    read -p "Describe file in short: " desc

    new_name="$(date +%Y-%m-%d)_${desc// /_}.pdf"

    if ocrmypdf --skip-text "$file" "$ARCHIVE_DIR/$new_name"; then

        exiftool -overwrite_original -Keywords="$tags" "$ARCHIVE_DIR/$new_name"

        rm "$file"

        echo "Processed $(basename "$file") to $ARCHIVE_DIR/$new_name"
    else
        echo "Warning: OCR failed for $(basename "$file") (likely a signed PDF)."
        echo "Moving original file without modifications to preserve the signature..."

        mv "$file" "$ARCHIVE_DIR/$new_name"

        echo "Moved $(basename "$file") to $ARCHIVE_DIR/$new_name (Skipped OCR & Tags)"
    fi
done
