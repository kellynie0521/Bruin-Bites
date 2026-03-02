#!/bin/bash

echo "🔍 Bruin Bites - Project Validation"
echo "===================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check 1: Correct project file exists
echo "1️⃣  Checking project file..."
if [ -f "Bruin Bites.xcodeproj/project.pbxproj" ]; then
    echo -e "   ${GREEN}✓${NC} Bruin Bites.xcodeproj found"
else
    echo -e "   ${RED}✗${NC} Bruin Bites.xcodeproj missing!"
    exit 1
fi

# Check 2: Firebase configuration exists
echo "2️⃣  Checking Firebase configuration..."
if [ -f "HOTH Project/GoogleService-Info.plist" ]; then
    echo -e "   ${GREEN}✓${NC} GoogleService-Info.plist found"
    
    # Check if it has valid content
    if grep -q "PROJECT_ID" "HOTH Project/GoogleService-Info.plist"; then
        echo -e "   ${GREEN}✓${NC} Firebase config appears valid"
    else
        echo -e "   ${YELLOW}⚠${NC}  Firebase config may be incomplete"
    fi
else
    echo -e "   ${RED}✗${NC} GoogleService-Info.plist missing!"
    echo "      Please download from Firebase Console"
fi

# Check 3: Source files exist
echo "3️⃣  Checking source files..."
REQUIRED_FILES=(
    "HOTH Project/HOTH_ProjectApp.swift"
    "HOTH Project/ViewModels/AuthViewModel.swift"
    "HOTH Project/ViewModels/MapViewModel.swift"
    "HOTH Project/Views/MainTabView.swift"
)

all_files_exist=true
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "   ${GREEN}✓${NC} $(basename "$file")"
    else
        echo -e "   ${RED}✗${NC} $(basename "$file") missing!"
        all_files_exist=false
    fi
done

# Check 4: Assets exist
echo "4️⃣  Checking assets..."
if [ -d "HOTH Project/Assets.xcassets" ]; then
    echo -e "   ${GREEN}✓${NC} Assets.xcassets found"
    
    # Check for app icon
    if [ -d "HOTH Project/Assets.xcassets/AppIcon.appiconset" ]; then
        echo -e "   ${GREEN}✓${NC} App icon configured"
    else
        echo -e "   ${YELLOW}⚠${NC}  App icon missing"
    fi
else
    echo -e "   ${RED}✗${NC} Assets.xcassets missing!"
fi

# Check 5: Xcode installed
echo "5️⃣  Checking Xcode installation..."
if command -v xcodebuild &> /dev/null; then
    XCODE_VERSION=$(xcodebuild -version | head -n 1)
    echo -e "   ${GREEN}✓${NC} $XCODE_VERSION"
else
    echo -e "   ${RED}✗${NC} Xcode not found!"
    echo "      Please install Xcode from the App Store"
fi

echo ""
echo "===================================="
if [ "$all_files_exist" = true ]; then
    echo -e "${GREEN}✓ Validation passed!${NC}"
    echo ""
    echo "Ready to run! Execute:"
    echo "  open \"Bruin Bites.xcodeproj\""
    echo ""
    echo "Or use the helper script:"
    echo "  ./RUN_PROJECT.sh"
else
    echo -e "${RED}✗ Validation failed${NC}"
    echo "Please check the errors above"
    exit 1
fi
