#!/usr/bin/env python3
"""
Documentation Coverage Checker

This script analyzes Swift source files and reports on documentation coverage.
It checks for:
- Public declarations without documentation
- Inconsistent documentation formatting
- Missing file headers
- Terminology consistency with the project glossary

Usage:
    python3 check_documentation.py [directory]

If no directory is specified, it will check the current directory.
"""

import os
import re
import sys
import glob
from collections import defaultdict

# Regex patterns
public_declaration_pattern = re.compile(r'(public|open)\s+(class|struct|enum|protocol|func|var|let)\s+(\w+)')
documentation_pattern = re.compile(r'///.*')
file_header_pattern = re.compile(r'//\n//\s+\w+\.swift\n//\s+\w+\n//\n//\s+Created by.*\n//.*\n//')
mark_pattern = re.compile(r'// MARK: - .*')

# Terminology to check for consistency
terminology = {
    'state': ['state', 'condition', 'data'],
    'action': ['action', 'event', 'message'],
    'reducer': ['reducer', 'logic', 'handler'],
    'effect': ['effect', 'side effect', 'async operation'],
    'store': ['store', 'container'],
    'view store': ['view store', 'view state'],
}

def check_file(file_path):
    """Check a single Swift file for documentation issues."""
    with open(file_path, 'r') as f:
        content = f.read()
        lines = content.split('\n')
    
    issues = []
    
    # Check for file header
    if not file_header_pattern.search(content):
        issues.append(f"Missing or invalid file header")
    
    # Check for public declarations without documentation
    public_declarations = public_declaration_pattern.finditer(content)
    for decl in public_declarations:
        # Get the line number of the declaration
        line_num = content[:decl.start()].count('\n')
        
        # Check if there's documentation above this declaration
        if line_num > 0:
            has_docs = False
            for i in range(line_num, 0, -1):
                if documentation_pattern.match(lines[i-1]):
                    has_docs = True
                    break
                elif not lines[i-1].strip() or mark_pattern.match(lines[i-1]):
                    continue
                else:
                    break
            
            if not has_docs:
                issues.append(f"Line {line_num+1}: Public declaration '{decl.group(0)}' is missing documentation")
    
    # Check for terminology consistency
    for term, alternatives in terminology.items():
        for alt in alternatives:
            if alt != term and alt in content.lower():
                issues.append(f"Terminology inconsistency: Using '{alt}' instead of '{term}'")
    
    return issues

def check_directory(directory):
    """Check all Swift files in a directory for documentation issues."""
    swift_files = glob.glob(f"{directory}/**/*.swift", recursive=True)
    
    all_issues = defaultdict(list)
    for file_path in swift_files:
        issues = check_file(file_path)
        if issues:
            all_issues[file_path] = issues
    
    return all_issues

def main():
    """Main entry point for the script."""
    directory = sys.argv[1] if len(sys.argv) > 1 else '.'
    
    print(f"Checking documentation in {directory}...")
    issues = check_directory(directory)
    
    if issues:
        print("\nDocumentation issues found:")
        for file_path, file_issues in issues.items():
            print(f"\n{file_path}:")
            for issue in file_issues:
                print(f"  - {issue}")
        print(f"\nTotal: {sum(len(issues) for issues in issues.values())} issues in {len(issues)} files")
        return 1
    else:
        print("No documentation issues found!")
        return 0

if __name__ == "__main__":
    sys.exit(main())