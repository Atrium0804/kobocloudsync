#!/bin/sh

# Create KoboRoot.tgz package for Kobo deployment
# This package will be extracted to the root filesystem when placed in .kobo/ folder

echo "========================================"
echo "Building KoboRoot.tgz package"
echo "========================================"
echo ""

# Clean up old files
echo "Cleaning up old files..."
rm -f .DS_Store
rm -f KoboRoot.tgz

# Fix line endings for BusyBox compatibility (CRLF -> LF)
echo "Converting line endings to Unix format (CRLF -> LF)..."
find src -type f \( -name '*.sh' -o -name '*.conf' \) -exec sed -i 's/\r$//' {} \; 2>/dev/null || \
find src -type f \( -name '*.sh' -o -name '*.conf' \) -exec dos2unix {} \; 2>/dev/null || \
echo "Warning: Could not convert line endings (sed/dos2unix not found)"

# Make scripts executable
echo "Setting execute permissions on scripts..."
find src -type f -name '*.sh' -exec chmod +x {} \;

# Create tar package
echo "Creating KoboRoot.tgz..."
tar -cvzf KoboRoot.tgz --exclude '.DS_Store' -C src mnt usr

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "KoboRoot.tgz created successfully!"
    echo "========================================"
    echo ""
    echo "To install on Kobo:"
    echo "  1. Copy KoboRoot.tgz to Kobo's .kobo folder"
    echo "  2. Safely eject Kobo"
    echo "  3. Kobo will update on next boot"
    echo ""
    echo "File size: $(du -h KoboRoot.tgz | cut -f1)"
else
    echo ""
    echo "ERROR: Failed to create KoboRoot.tgz"
    exit 1
fi


