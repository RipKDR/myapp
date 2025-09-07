#!/bin/bash

# NDIS Connect - App Icon Generation Script
# This script generates all required app icons for iOS and Android

echo "🎨 Generating NDIS Connect App Icons..."

# Create directories
mkdir -p android/app/src/main/res/mipmap-hdpi
mkdir -p android/app/src/main/res/mipmap-mdpi
mkdir -p android/app/src/main/res/mipmap-xhdpi
mkdir -p android/app/src/main/res/mipmap-xxhdpi
mkdir -p android/app/src/main/res/mipmap-xxxhdpi
mkdir -p ios/Runner/Assets.xcassets/AppIcon.appiconset

# Source SVG file
SOURCE_SVG="assets/app_icon.svg"

# Check if source exists
if [ ! -f "$SOURCE_SVG" ]; then
    echo "❌ Source SVG not found: $SOURCE_SVG"
    exit 1
fi

# Android icon sizes
echo "📱 Generating Android icons..."
convert "$SOURCE_SVG" -resize 48x48 android/app/src/main/res/mipmap-mdpi/ic_launcher.png
convert "$SOURCE_SVG" -resize 72x72 android/app/src/main/res/mipmap-hdpi/ic_launcher.png
convert "$SOURCE_SVG" -resize 96x96 android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
convert "$SOURCE_SVG" -resize 144x144 android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
convert "$SOURCE_SVG" -resize 192x192 android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

# Android adaptive icons (foreground)
convert "$SOURCE_SVG" -resize 108x108 android/app/src/main/res/mipmap-mdpi/ic_launcher_foreground.png
convert "$SOURCE_SVG" -resize 162x162 android/app/src/main/res/mipmap-hdpi/ic_launcher_foreground.png
convert "$SOURCE_SVG" -resize 216x216 android/app/src/main/res/mipmap-xhdpi/ic_launcher_foreground.png
convert "$SOURCE_SVG" -resize 324x324 android/app/src/main/res/mipmap-xxhdpi/ic_launcher_foreground.png
convert "$SOURCE_SVG" -resize 432x432 android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground.png

# iOS icon sizes
echo "🍎 Generating iOS icons..."
convert "$SOURCE_SVG" -resize 20x20 ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-20.png
convert "$SOURCE_SVG" -resize 29x29 ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-29.png
convert "$SOURCE_SVG" -resize 40x40 ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-40.png
convert "$SOURCE_SVG" -resize 58x58 ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-58.png
convert "$SOURCE_SVG" -resize 60x60 ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-60.png
convert "$SOURCE_SVG" -resize 76x76 ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-76.png
convert "$SOURCE_SVG" -resize 80x80 ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-80.png
convert "$SOURCE_SVG" -resize 87x87 ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-87.png
convert "$SOURCE_SVG" -resize 114x114 ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-114.png
convert "$SOURCE_SVG" -resize 120x120 ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-120.png
convert "$SOURCE_SVG" -resize 152x152 ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-152.png
convert "$SOURCE_SVG" -resize 167x167 ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-167.png
convert "$SOURCE_SVG" -resize 180x180 ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-180.png
convert "$SOURCE_SVG" -resize 1024x1024 ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-1024.png

# Create iOS Contents.json
cat > ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json << 'EOF'
{
  "images" : [
    {
      "filename" : "icon-20.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "icon-20.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "filename" : "icon-29.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "icon-29.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "filename" : "icon-40.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "icon-40.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "filename" : "icon-60.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "filename" : "icon-60.png",
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
      "filename" : "icon-20.png",
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
      "filename" : "icon-29.png",
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
      "filename" : "icon-40.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "icon-76.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "76x76"
    },
    {
      "filename" : "icon-76.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "76x76"
    },
    {
      "filename" : "icon-83.5.png",
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

# Store assets
echo "🏪 Generating store assets..."
mkdir -p store_assets/icons
convert "$SOURCE_SVG" -resize 512x512 store_assets/icons/app_icon_512.png
convert "$SOURCE_SVG" -resize 1024x1024 store_assets/icons/app_icon_1024.png

# Feature graphic for Google Play (1024x500)
convert "$SOURCE_SVG" -resize 500x500 -background "#4F46E5" -gravity center -extent 1024x500 store_assets/icons/feature_graphic.png

echo "✅ App icons generated successfully!"
echo "📁 Android icons: android/app/src/main/res/mipmap-*/"
echo "📁 iOS icons: ios/Runner/Assets.xcassets/AppIcon.appiconset/"
echo "📁 Store assets: store_assets/icons/"