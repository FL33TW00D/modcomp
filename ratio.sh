#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

filename="$1"

if [ ! -f "$filename" ]; then
    echo "File does not exist: $filename"
    exit 1
fi

echo "Compressing with Brotli..."
brotli -q 11 -o "${filename}.br" "$filename"
echo "Compressing with Zstd..."
zstd --ultra -22 -T8 -o "${filename}.zst" "$filename"

if [[ "$(uname)" == "Linux" ]]; then
  stat_option="-c%s"
elif [[ "$(uname)" == "Darwin" ]]; then
  stat_option="-f%z"
else
  echo "Unsupported OS for this script."
  exit 1
fi

original_size=$(stat $stat_option "$filename")

compressed_size_brotli=$(stat $stat_option "${filename}.br")
compressed_size_zstd=$(stat $stat_option "${filename}.zst")

compression_ratio_brotli=$(echo "scale=2; $original_size / $compressed_size_brotli" | bc)
compression_ratio_zstd=$(echo "scale=2; $original_size / $compressed_size_zstd" | bc)
compression_percentage_brotli=$(echo "scale=2; (1 - $compressed_size_brotli / $original_size) * 100" | bc)
compression_percentage_zstd=$(echo "scale=2; (1 - $compressed_size_zstd / $original_size) * 100" | bc)

# Print results
echo "Compression results for: $filename"
echo "Brotli Compression Ratio: $compression_ratio_brotli"
echo "Brotli Compression Percentage: $compression_percentage_brotli%"
echo "Zstd Compression Ratio: $compression_ratio_zstd"
echo "Zstd Compression Percentage: $compression_percentage_zstd%"

