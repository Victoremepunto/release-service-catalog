#!/usr/bin/env bash
# Standalone test to demonstrate the gzipped file handling bug and fix

set -e

echo "=== Testing gzipped disk image handling ==="
echo

# Create test directory
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

cd "$TEST_DIR"

# Create a fake gzipped disk image
echo "Creating test files..."
echo "fake raw disk image" > disk.raw
gzip disk.raw
echo "✓ Created disk.raw.gz"
echo

# Test scenario
SOURCE="disk.raw.gz"
FILENAME="rhel-ai-cuda-aws-3.3-1776076829-x86_64.raw.gz"

echo "=== BEFORE FIX (buggy code) ==="
echo "SOURCE=$SOURCE"
echo "FILENAME=$FILENAME"
echo

# Old buggy logic
echo "1. Checking for decompression:"
if [ -f "${SOURCE}.gz" ]; then
    echo "   Would decompress: ${SOURCE}.gz"
else
    echo "   ✗ File ${SOURCE}.gz not found (looking for wrong file!)"
fi
echo

echo "2. Checking file extension:"
FILE_EXT="${FILENAME##*.}"
echo "   Extension extracted: '$FILE_EXT'"
if [ "${FILE_EXT}" = "raw" ]; then
    echo "   ✓ Would process as AMI"
elif [ "${FILE_EXT}" = "vhd" ]; then
    echo "   ✓ Would process as VHD"
else
    echo "   ✗ SKIPPED - extension not recognized!"
fi
echo

echo "=== AFTER FIX (corrected code) ==="
echo

# New fixed logic
echo "1. Checking for decompression:"
if [ -f "${SOURCE}" ] && [[ "${SOURCE}" == *.gz ]]; then
    echo "   ✓ File exists and is gzipped"
    gzip -d "${SOURCE}"
    SOURCE="${SOURCE%.gz}"
    echo "   ✓ Decompressed to: $SOURCE"
else
    echo "   File not gzipped or doesn't exist"
fi
echo

echo "2. Checking file extension:"
FILENAME_BASE="${FILENAME%.gz}"
FILE_EXT="${FILENAME_BASE##*.}"
echo "   Stripped .gz: $FILENAME_BASE"
echo "   Extension extracted: '$FILE_EXT'"
if [ "${FILE_EXT}" = "raw" ]; then
    echo "   ✓ Processing as AMI image type"
elif [ "${FILE_EXT}" = "vhd" ]; then
    echo "   ✓ Processing as VHD image type"
else
    echo "   ✗ SKIPPED"
fi
echo

# Verify the decompressed file exists
if [ -f "disk.raw" ]; then
    echo "=== RESULT ==="
    echo "✓ File successfully decompressed and would be processed"
else
    echo "=== RESULT ==="
    echo "✗ File was not decompressed"
fi
