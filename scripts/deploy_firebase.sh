#!/bin/bash

# NDIS Connect - Firebase Production Deployment Script
# This script deploys Firebase services for production

set -e

echo "🔥 Deploying NDIS Connect to Firebase Production..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    print_error "Firebase CLI is not installed. Please install it first:"
    echo "npm install -g firebase-tools"
    exit 1
fi

# Check if user is logged in
if ! firebase projects:list &> /dev/null; then
    print_error "Not logged in to Firebase. Please login first:"
    echo "firebase login"
    exit 1
fi

# Check if firebase.json exists
if [ ! -f "firebase.json" ]; then
    print_error "firebase.json not found. Please initialize Firebase first:"
    echo "firebase init"
    exit 1
fi

# Confirm production deployment
print_warning "This will deploy to PRODUCTION Firebase project!"
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Deployment cancelled"
    exit 0
fi

# Select Firebase project
print_status "Available Firebase projects:"
firebase projects:list

read -p "Enter the production project ID: " PROJECT_ID
if [ -z "$PROJECT_ID" ]; then
    print_error "Project ID is required"
    exit 1
fi

# Set the project
print_status "Setting Firebase project to: $PROJECT_ID"
firebase use $PROJECT_ID

# Deploy Firestore security rules
print_status "Deploying Firestore security rules..."
if firebase deploy --only firestore:rules; then
    print_success "Firestore security rules deployed successfully!"
else
    print_error "Failed to deploy Firestore security rules"
    exit 1
fi

# Deploy Firestore indexes
print_status "Deploying Firestore indexes..."
if firebase deploy --only firestore:indexes; then
    print_success "Firestore indexes deployed successfully!"
else
    print_warning "Failed to deploy Firestore indexes (may not exist)"
fi

# Deploy Firebase Functions (if they exist)
if [ -d "functions" ]; then
    print_status "Deploying Firebase Functions..."
    if firebase deploy --only functions; then
        print_success "Firebase Functions deployed successfully!"
    else
        print_error "Failed to deploy Firebase Functions"
        exit 1
    fi
else
    print_status "No Firebase Functions found, skipping..."
fi

# Deploy Firebase Hosting (if configured)
if grep -q "hosting" firebase.json; then
    print_status "Deploying Firebase Hosting..."
    if firebase deploy --only hosting; then
        print_success "Firebase Hosting deployed successfully!"
    else
        print_error "Failed to deploy Firebase Hosting"
        exit 1
    fi
else
    print_status "Firebase Hosting not configured, skipping..."
fi

# Deploy Firebase Storage rules (if they exist)
if [ -f "storage.rules" ]; then
    print_status "Deploying Firebase Storage rules..."
    if firebase deploy --only storage; then
        print_success "Firebase Storage rules deployed successfully!"
    else
        print_error "Failed to deploy Firebase Storage rules"
        exit 1
    fi
else
    print_status "No Firebase Storage rules found, skipping..."
fi

# Deploy all remaining services
print_status "Deploying remaining Firebase services..."
if firebase deploy; then
    print_success "All Firebase services deployed successfully!"
else
    print_error "Failed to deploy some Firebase services"
    exit 1
fi

# Verify deployment
print_status "Verifying deployment..."
firebase projects:list | grep $PROJECT_ID

# Create deployment summary
print_status "Creating deployment summary..."
cat > DEPLOYMENT_SUMMARY.md << EOF
# NDIS Connect - Firebase Production Deployment Summary

## Deployment Information
- **Deployment Date**: $(date)
- **Project ID**: $PROJECT_ID
- **Deployment Type**: Production
- **Firebase CLI Version**: $(firebase --version)

## Deployed Services
- **Firestore Rules**: ✅ Deployed
- **Firestore Indexes**: ✅ Deployed
- **Firebase Functions**: $(if [ -d "functions" ]; then echo "✅ Deployed"; else echo "❌ Not configured"; fi)
- **Firebase Hosting**: $(if grep -q "hosting" firebase.json; then echo "✅ Deployed"; else echo "❌ Not configured"; fi)
- **Firebase Storage**: $(if [ -f "storage.rules" ]; then echo "✅ Deployed"; else echo "❌ Not configured"; fi)

## Security Rules
- **Firestore**: Production security rules active
- **Storage**: $(if [ -f "storage.rules" ]; then echo "Production storage rules active"; else echo "No storage rules configured"; fi)

## Next Steps
1. Update Flutter app with production Firebase configuration
2. Test all Firebase services in production
3. Monitor Firebase console for any issues
4. Set up monitoring and alerting

## Firebase Console
- **Project Console**: https://console.firebase.google.com/project/$PROJECT_ID
- **Firestore**: https://console.firebase.google.com/project/$PROJECT_ID/firestore
- **Functions**: https://console.firebase.google.com/project/$PROJECT_ID/functions
- **Hosting**: https://console.firebase.google.com/project/$PROJECT_ID/hosting

## Support
- **Firebase Documentation**: https://firebase.google.com/docs
- **Firebase Support**: https://firebase.google.com/support
- **NDIS Connect Documentation**: docs/ directory
EOF

print_success "Deployment summary created: DEPLOYMENT_SUMMARY.md"

# Final status
print_success "🎉 Firebase production deployment completed successfully!"
print_status "All services are now live in production"
print_status "Review DEPLOYMENT_SUMMARY.md for details"

# Display important URLs
echo
print_status "Important URLs:"
echo "  🔥 Firebase Console: https://console.firebase.google.com/project/$PROJECT_ID"
echo "  📊 Firestore: https://console.firebase.google.com/project/$PROJECT_ID/firestore"
echo "  ⚡ Functions: https://console.firebase.google.com/project/$PROJECT_ID/functions"
echo "  🌐 Hosting: https://console.firebase.google.com/project/$PROJECT_ID/hosting"

echo
print_status "Production deployment complete! 🚀"