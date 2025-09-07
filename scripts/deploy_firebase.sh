#!/bin/bash

# NDIS Connect - Firebase Production Deployment Script
# This script deploys the app to Firebase production environment

set -e

echo "🔥 NDIS Connect - Firebase Production Deployment"
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="NDIS Connect"
FIREBASE_PROJECT_ID="ndis-connect-prod"

echo -e "${BLUE}Deploying $PROJECT_NAME to Firebase Production${NC}"

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}❌ Firebase CLI is not installed${NC}"
    echo -e "${YELLOW}Install with: npm install -g firebase-tools${NC}"
    exit 1
fi

# Check if logged in to Firebase
if ! firebase projects:list &> /dev/null; then
    echo -e "${RED}❌ Not logged in to Firebase${NC}"
    echo -e "${YELLOW}Login with: firebase login${NC}"
    exit 1
fi

# Verify Firebase project
echo -e "${BLUE}🔍 Verifying Firebase project...${NC}"
if ! firebase use "$FIREBASE_PROJECT_ID" &> /dev/null; then
    echo -e "${RED}❌ Firebase project '$FIREBASE_PROJECT_ID' not found or not accessible${NC}"
    echo -e "${YELLOW}Available projects:${NC}"
    firebase projects:list
    exit 1
fi

echo -e "${GREEN}✅ Using Firebase project: $FIREBASE_PROJECT_ID${NC}"

# Deploy Firestore security rules
echo -e "${YELLOW}🔒 Deploying Firestore security rules...${NC}"
firebase deploy --only firestore:rules
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Firestore security rules deployed successfully${NC}"
else
    echo -e "${RED}❌ Firestore security rules deployment failed${NC}"
    exit 1
fi

# Deploy Firebase Functions (if any)
echo -e "${YELLOW}⚡ Deploying Firebase Functions...${NC}"
if [ -d "functions" ]; then
    firebase deploy --only functions
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Firebase Functions deployed successfully${NC}"
    else
        echo -e "${RED}❌ Firebase Functions deployment failed${NC}"
        exit 1
    fi
else
    echo -e "${BLUE}ℹ️  No Firebase Functions found, skipping...${NC}"
fi

# Deploy Firebase Hosting (if configured)
echo -e "${YELLOW}🌐 Deploying Firebase Hosting...${NC}"
if [ -f "firebase.json" ] && grep -q "hosting" firebase.json; then
    firebase deploy --only hosting
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Firebase Hosting deployed successfully${NC}"
    else
        echo -e "${RED}❌ Firebase Hosting deployment failed${NC}"
        exit 1
    fi
else
    echo -e "${BLUE}ℹ️  Firebase Hosting not configured, skipping...${NC}"
fi

# Deploy Firebase Storage rules (if any)
echo -e "${YELLOW}📁 Deploying Firebase Storage rules...${NC}"
if [ -f "storage.rules" ]; then
    firebase deploy --only storage
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Firebase Storage rules deployed successfully${NC}"
    else
        echo -e "${RED}❌ Firebase Storage rules deployment failed${NC}"
        exit 1
    fi
else
    echo -e "${BLUE}ℹ️  No Firebase Storage rules found, skipping...${NC}"
fi

# Generate Firebase configuration for Flutter
echo -e "${YELLOW}🔧 Generating Firebase configuration...${NC}"
if command -v flutterfire &> /dev/null; then
    flutterfire configure --project="$FIREBASE_PROJECT_ID" --platforms=android,ios
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Firebase configuration generated successfully${NC}"
    else
        echo -e "${RED}❌ Firebase configuration generation failed${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  FlutterFire CLI not found. Install with: dart pub global activate flutterfire_cli${NC}"
fi

# Display deployment summary
echo -e "${GREEN}🎉 Firebase deployment completed successfully!${NC}"
echo ""
echo -e "${BLUE}Deployment Summary:${NC}"
echo -e "  Project: $FIREBASE_PROJECT_ID"
echo -e "  Firestore Rules: ✅ Deployed"
echo -e "  Functions: $([ -d "functions" ] && echo "✅ Deployed" || echo "ℹ️  Not configured")"
echo -e "  Hosting: $([ -f "firebase.json" ] && grep -q "hosting" firebase.json && echo "✅ Deployed" || echo "ℹ️  Not configured")"
echo -e "  Storage Rules: $([ -f "storage.rules" ] && echo "✅ Deployed" || echo "ℹ️  Not configured")"
echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo -e "  1. Update app with new Firebase configuration"
echo -e "  2. Test app with production Firebase backend"
echo -e "  3. Monitor Firebase console for any issues"
echo -e "  4. Set up monitoring and alerts"
echo ""
echo -e "${GREEN}✅ Firebase deployment script completed successfully!${NC}"
