#!/bin/bash
#
# Documentation Linting Script for APICallsWithTCA
#
# This script checks Swift files for proper documentation format
# and reports any issues found.
#

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo "Running documentation linting..."
echo ""

# Check for files without file headers
echo "Checking for missing file headers..."
FILES_WITHOUT_HEADERS=$(find . -name "*.swift" -type f -exec grep -L "///" {} \;)
if [ -z "$FILES_WITHOUT_HEADERS" ]; then
    echo -e "${GREEN}✓ All Swift files have documentation headers${NC}"
else
    echo -e "${RED}✗ The following files are missing documentation headers:${NC}"
    echo "$FILES_WITHOUT_HEADERS"
    echo ""
fi

# Check for public APIs without documentation
echo "Checking for undocumented public APIs..."
PUBLIC_APIS_WITHOUT_DOCS=$(find . -name "*.swift" -type f -exec grep -l "public " {} \; | xargs grep -l "public " | xargs grep -L "///" | sort -u)
if [ -z "$PUBLIC_APIS_WITHOUT_DOCS" ]; then
    echo -e "${GREEN}✓ All public APIs are documented${NC}"
else
    echo -e "${RED}✗ The following files contain undocumented public APIs:${NC}"
    echo "$PUBLIC_APIS_WITHOUT_DOCS"
    echo ""
fi

# Check for functions without documentation
echo "Checking for undocumented functions..."
FUNCS_WITHOUT_DOCS=$(find . -name "*.swift" -type f -exec grep -l "func " {} \; | xargs cat | grep -n "func " | grep -v "///" | wc -l)
if [ "$FUNCS_WITHOUT_DOCS" -eq "0" ]; then
    echo -e "${GREEN}✓ All functions are documented${NC}"
else
    echo -e "${YELLOW}⚠ Found approximately $FUNCS_WITHOUT_DOCS functions without documentation${NC}"
    echo ""
fi

# Check for proper documentation comment format
echo "Checking for proper documentation comment format..."
IMPROPER_DOCS=$(find . -name "*.swift" -type f -exec grep -l "//" {} \; | xargs grep -l "^[[:space:]]*// " | sort -u)
if [ -z "$IMPROPER_DOCS" ]; then
    echo -e "${GREEN}✓ All documentation uses proper comment format${NC}"
else
    echo -e "${YELLOW}⚠ The following files may use // instead of /// for documentation:${NC}"
    echo "$IMPROPER_DOCS"
    echo ""
fi

echo "Documentation linting complete."