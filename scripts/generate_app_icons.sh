#!/bin/bash

# NDIS Connect - App Icon Generation Script
# This script generates app icons for all required sizes

set -e

echo "🎨 NDIS Connect - App Icon Generation"
echo "===================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SOURCE_ICON="assets/app_icon.svg"
OUTPUT_DIR="assets/icons"
ANDROID_DIR="android/app/src/main/res"
IOS_DIR="ios/Runner/Assets.xcassets/AppIcon.appiconset"

echo -e "${BLUE}Generating app icons for NDIS Connect${NC}"

# Check if source icon exists
if [ ! -f "$SOURCE_ICON" ]; then
    echo -e "${RED}❌ Source icon not found: $SOURCE_ICON${NC}"
    echo -e "${YELLOW}Please create a high-resolution SVG icon (1024x1024 recommended)${NC}"
    exit 1
fi

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo -e "${RED}❌ ImageMagick is not installed${NC}"
    echo -e "${YELLOW}Install with: brew install imagemagick (macOS) or apt-get install imagemagick (Ubuntu)${NC}"
    exit 1
fi

# Create output directories
mkdir -p "$OUTPUT_DIR"
mkdir -p "$ANDROID_DIR"
mkdir -p "$IOS_DIR"

echo -e "${YELLOW}📱 Generating Android icons...${NC}"

# Android icon sizes
declare -A android_icons=(
    ["mipmap-mdpi/ic_launcher.png"]="48"
    ["mipmap-hdpi/ic_launcher.png"]="72"
    ["mipmap-xhdpi/ic_launcher.png"]="96"
    ["mipmap-xxhdpi/ic_launcher.png"]="144"
    ["mipmap-xxxhdpi/ic_launcher.png"]="192"
    ["mipmap-mdpi/ic_launcher_round.png"]="48"
    ["mipmap-hdpi/ic_launcher_round.png"]="72"
    ["mipmap-xhdpi/ic_launcher_round.png"]="96"
    ["mipmap-xxhdpi/ic_launcher_round.png"]="144"
    ["mipmap-xxxhdpi/ic_launcher_round.png"]="192"
    ["drawable-mdpi/ic_notification.png"]="24"
    ["drawable-hdpi/ic_notification.png"]="36"
    ["drawable-xhdpi/ic_notification.png"]="48"
    ["drawable-xxhdpi/ic_notification.png"]="72"
    ["drawable-xxxhdpi/ic_notification.png"]="96"
)

# Generate Android icons
for icon_path in "${!android_icons[@]}"; do
    size="${android_icons[$icon_path]}"
    full_path="$ANDROID_DIR/$icon_path"
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$full_path")"
    
    # Generate icon
    convert "$SOURCE_ICON" -resize "${size}x${size}" "$full_path"
    echo -e "  ✅ Generated $icon_path (${size}x${size})"
done

echo -e "${YELLOW}🍎 Generating iOS icons...${NC}"

# iOS icon sizes
declare -A ios_icons=(
    ["icon-20.png"]="20"
    ["icon-20@2x.png"]="40"
    ["icon-20@3x.png"]="60"
    ["icon-29.png"]="29"
    ["icon-29@2x.png"]="58"
    ["icon-29@3x.png"]="87"
    ["icon-40.png"]="40"
    ["icon-40@2x.png"]="80"
    ["icon-40@3x.png"]="120"
    ["icon-50.png"]="50"
    ["icon-50@2x.png"]="100"
    ["icon-57.png"]="57"
    ["icon-57@2x.png"]="114"
    ["icon-60@2x.png"]="120"
    ["icon-60@3x.png"]="180"
    ["icon-72.png"]="72"
    ["icon-72@2x.png"]="144"
    ["icon-76.png"]="76"
    ["icon-76@2x.png"]="152"
    ["icon-83.5@2x.png"]="167"
    ["icon-1024.png"]="1024"
)

# Generate iOS icons
for icon_name in "${!ios_icons[@]}"; do
    size="${ios_icons[$icon_name]}"
    full_path="$IOS_DIR/$icon_name"
    
    # Generate icon
    convert "$SOURCE_ICON" -resize "${size}x${size}" "$full_path"
    echo -e "  ✅ Generated $icon_name (${size}x${size})"
done

# Create iOS Contents.json
echo -e "${YELLOW}📝 Creating iOS Contents.json...${NC}"
cat > "$IOS_DIR/Contents.json" << 'EOF'
{
  "images" : [
    {
      "filename" : "icon-20.png",
      "idiom" : "iphone",
      "scale" : "1x",
      "size" : "20x20"
    },
    {
      "filename" : "icon-20@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "icon-20@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "filename" : "icon-29.png",
      "idiom" : "iphone",
      "scale" : "1x",
      "size" : "29x29"
    },
    {
      "filename" : "icon-29@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "icon-29@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "filename" : "icon-40.png",
      "idiom" : "iphone",
      "scale" : "1x",
      "size" : "40x40"
    },
    {
      "filename" : "icon-40@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "icon-40@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "filename" : "icon-60@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "filename" : "icon-60@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60"
    },
    {
      "filename" : "icon-20.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "20x20"
    },
    {
      "filename" : "icon-20@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "icon-29.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "29x29"
    },
    {
      "filename" : "icon-29@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "icon-40.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "40x40"
    },
    {
      "filename" : "icon-40@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "icon-50.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "50x50"
    },
    {
      "filename" : "icon-50@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "50x50"
    },
    {
      "filename" : "icon-72.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "72x72"
    },
    {
      "filename" : "icon-72@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "72x72"
    },
    {
      "filename" : "icon-76.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "76x76"
    },
    {
      "filename" : "icon-76@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "76x76"
    },
    {
      "filename" : "icon-83.5@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "83.5x83.5"
    },
    {
      "filename" : "icon-1024.png",
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Create store-ready icons
echo -e "${YELLOW}🏪 Generating store-ready icons...${NC}"
convert "$SOURCE_ICON" -resize "512x512" "$OUTPUT_DIR/play-store-icon.png"
convert "$SOURCE_ICON" -resize "1024x1024" "$OUTPUT_DIR/app-store-icon.png"
convert "$SOURCE_ICON" -resize "1024x1024" "$OUTPUT_DIR/feature-graphic.png"

# Create adaptive icon for Android
echo -e "${YELLOW}🎯 Creating Android adaptive icon...${NC}"
mkdir -p "$ANDROID_DIR/mipmap-anydpi-v26"

cat > "$ANDROID_DIR/mipmap-anydpi-v26/ic_launcher.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>
EOF

cat > "$ANDROID_DIR/mipmap-anydpi-v26/ic_launcher_round.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>
EOF

# Generate adaptive icon layers
convert "$SOURCE_ICON" -resize "108x108" -background transparent -gravity center -extent 108x108 "$ANDROID_DIR/drawable-xxxhdpi/ic_launcher_foreground.png"
convert -size 108x108 xc:"#FFFFFF" "$ANDROID_DIR/drawable-xxxhdpi/ic_launcher_background.png"

# Display summary
echo -e "${GREEN}🎉 App icon generation completed successfully!${NC}"
echo ""
echo -e "${BLUE}Generated Icons:${NC}"
echo -e "  Android: $(find "$ANDROID_DIR" -name "*.png" | wc -l) icons"
echo -e "  iOS: $(find "$IOS_DIR" -name "*.png" | wc -l) icons"
echo -e "  Store: 3 marketing icons"
echo ""
echo -e "${YELLOW}📁 Icon Locations:${NC}"
echo -e "  Android: $ANDROID_DIR/"
echo -e "  iOS: $IOS_DIR/"
echo -e "  Store: $OUTPUT_DIR/"
echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo -e "  1. Test icons on different devices"
echo -e "  2. Update app manifest files if needed"
echo -e "  3. Use store icons for app store submissions"
echo -e "  4. Consider creating feature graphics for stores"
echo ""
echo -e "${GREEN}✅ App icon generation script completed successfully!${NC}"
