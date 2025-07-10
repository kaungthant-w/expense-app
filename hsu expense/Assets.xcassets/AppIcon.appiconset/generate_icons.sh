#!/bin/zsh
# This script will generate all required iOS app icon sizes from ItunesArtwork@2x.png
# Place this script in the AppIcon.appiconset directory and run it there.

set -e

SRC="ItunesArtwork@2x.png"
if [ ! -f "$SRC" ]; then
  echo "ItunesArtwork@2x.png not found!"
  exit 1
fi

declare -A icons=(
  ["Icon-App-20x20@1x.png"]="20"
  ["Icon-App-20x20@2x.png"]="40"
  ["Icon-App-20x20@3x.png"]="60"
  ["Icon-App-29x29@1x.png"]="29"
  ["Icon-App-29x29@2x.png"]="58"
  ["Icon-App-29x29@3x.png"]="87"
  ["Icon-App-40x40@1x.png"]="40"
  ["Icon-App-40x40@2x.png"]="80"
  ["Icon-App-40x40@3x.png"]="120"
  ["Icon-App-60x60@2x.png"]="120"
  ["Icon-App-60x60@3x.png"]="180"
  ["Icon-App-76x76@1x.png"]="76"
  ["Icon-App-76x76@2x.png"]="152"
  ["Icon-App-83.5x83.5@2x.png"]="167"
)

echo "Generating icons from $SRC..."
for name size in ${(kv)icons}; do
  echo "  $name ($size x $size)"
  convert "$SRC" -resize ${size}x${size} "$name"
done

echo "All icons generated."
