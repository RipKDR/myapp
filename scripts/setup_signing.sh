#!/bin/bash

# NDIS Connect - App Signing Setup Script
# This script helps set up app signing for production builds

set -e

echo "🔐 NDIS Connect - App Signing Setup"
echo "==================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
KEYSTORE_NAME="ndis-connect-release.keystore"
KEYSTORE_ALIAS="ndis-connect-release"
KEYSTORE_DIR="android/app"
VALIDITY_DAYS=10000

echo -e "${BLUE}Setting up app signing for NDIS Connect${NC}"

# Check if keystore already exists
if [ -f "$KEYSTORE_DIR/$KEYSTORE_NAME" ]; then
    echo -e "${YELLOW}⚠️  Keystore already exists at $KEYSTORE_DIR/$KEYSTORE_NAME${NC}"
    read -p "Do you want to create a new keystore? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}ℹ️  Using existing keystore${NC}"
        exit 0
    fi
fi

# Create keystore directory if it doesn't exist
mkdir -p "$KEYSTORE_DIR"

echo -e "${YELLOW}🔑 Creating new keystore...${NC}"
echo -e "${BLUE}Please provide the following information:${NC}"

# Get keystore information
read -p "Keystore password: " -s KEYSTORE_PASSWORD
echo
read -p "Key password: " -s KEY_PASSWORD
echo
read -p "Your name: " KEY_NAME
read -p "Your organization: " KEY_ORG
read -p "Your organizational unit: " KEY_ORG_UNIT
read -p "Your city: " KEY_CITY
read -p "Your state/province: " KEY_STATE
read -p "Your country code (e.g., AU): " KEY_COUNTRY

# Create the keystore
keytool -genkey -v -keystore "$KEYSTORE_DIR/$KEYSTORE_NAME" \
    -alias "$KEYSTORE_ALIAS" \
    -keyalg RSA \
    -keysize 2048 \
    -validity "$VALIDITY_DAYS" \
    -storepass "$KEYSTORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" \
    -dname "CN=$KEY_NAME, OU=$KEY_ORG_UNIT, O=$KEY_ORG, L=$KEY_CITY, ST=$KEY_STATE, C=$KEY_COUNTRY"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Keystore created successfully${NC}"
else
    echo -e "${RED}❌ Keystore creation failed${NC}"
    exit 1
fi

# Create key.properties file
echo -e "${YELLOW}📝 Creating key.properties file...${NC}"
cat > "$KEYSTORE_DIR/key.properties" << EOF
storePassword=$KEYSTORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=$KEYSTORE_ALIAS
storeFile=$KEYSTORE_NAME
EOF

# Update build.gradle to use the keystore
echo -e "${YELLOW}🔧 Updating build.gradle...${NC}"
cat > "$KEYSTORE_DIR/build.gradle.patch" << 'EOF'
// Load keystore properties
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            // ... rest of release config
        }
    }
}
EOF

# Create backup instructions
echo -e "${YELLOW}💾 Creating backup instructions...${NC}"
cat > "$KEYSTORE_DIR/BACKUP_INSTRUCTIONS.txt" << EOF
NDIS Connect - Keystore Backup Instructions
==========================================

IMPORTANT: Keep your keystore and passwords safe!

Files to backup:
- $KEYSTORE_NAME (keystore file)
- key.properties (password file)

Backup locations:
1. Secure cloud storage (encrypted)
2. External encrypted drive
3. Secure password manager
4. Multiple physical locations

Security notes:
- Never commit keystore files to version control
- Use strong, unique passwords
- Store passwords separately from keystore
- Test keystore restoration regularly

If you lose your keystore:
- You cannot update your app on Google Play Store
- You must create a new app listing
- All existing users will need to uninstall and reinstall

Created: $(date)
EOF

# Set proper permissions
chmod 600 "$KEYSTORE_DIR/$KEYSTORE_NAME"
chmod 600 "$KEYSTORE_DIR/key.properties"

echo -e "${GREEN}🎉 App signing setup completed successfully!${NC}"
echo ""
echo -e "${BLUE}Setup Summary:${NC}"
echo -e "  Keystore: $KEYSTORE_DIR/$KEYSTORE_NAME"
echo -e "  Alias: $KEYSTORE_ALIAS"
echo -e "  Validity: $VALIDITY_DAYS days"
echo -e "  Properties: $KEYSTORE_DIR/key.properties"
echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo -e "  1. Update android/app/build.gradle to use the keystore"
echo -e "  2. Test the signing configuration with a release build"
echo -e "  3. Backup your keystore and passwords securely"
echo -e "  4. Add keystore files to .gitignore"
echo ""
echo -e "${RED}⚠️  IMPORTANT SECURITY REMINDERS:${NC}"
echo -e "  - Never commit keystore files to version control"
echo -e "  - Store passwords in a secure password manager"
echo -e "  - Create multiple backups in different locations"
echo -e "  - Test keystore restoration regularly"
echo ""
echo -e "${GREEN}✅ App signing setup script completed successfully!${NC}"
