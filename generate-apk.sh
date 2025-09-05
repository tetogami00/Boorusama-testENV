#!/bin/bash
set -e

#==============================================================================
# Generate Boorusama Dev APK via GitHub Actions
#==============================================================================
# This script provides instructions and shortcuts for generating the dev APK
# using the configured GitHub Actions workflows.

# Colors for output
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[ℹ]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

show_apk_generation_guide() {
    echo "=== 📱 Boorusama Dev APK Generation ==="
    echo
    
    print_status "Build environment is ready and validated!"
    echo
    
    # Extract app info
    local version
    version=$(grep '^version: ' pubspec.yaml | cut -d ' ' -f 2 | tr -d '\r')
    
    print_info "App Configuration:"
    echo "  • App Name: Boorusama Dev"
    echo "  • Version: $version"
    echo "  • Flavor: dev"
    echo "  • Expected APK: boorusama-${version}-dev.apk"
    echo
    
    print_info "🚀 APK Generation Methods:"
    echo
    
    echo "┌─ Method 1: Dev Build Workflow (Recommended) ─┐"
    echo "│                                              │"
    echo "│ 1. Go to GitHub Actions:                     │"
    echo "│    https://github.com/tetogami00/Boorusama-testENV/actions │"
    echo "│                                              │"
    echo "│ 2. Click 'Dev Build' workflow                │"
    echo "│ 3. Click 'Run workflow' button               │"
    echo "│ 4. Select 'release mode: true' (recommended) │"
    echo "│ 5. Click 'Run workflow' to start build       │"
    echo "│ 6. Wait 5-10 minutes for completion          │"
    echo "│ 7. Download APK from 'Artifacts' section     │"
    echo "│                                              │"
    echo "└──────────────────────────────────────────────┘"
    echo
    
    echo "┌─ Method 2: Main Build Workflow ──────────────┐"
    echo "│                                              │"
    echo "│ 1. Go to GitHub Actions:                     │"
    echo "│    https://github.com/tetogami00/Boorusama-testENV/actions │"
    echo "│                                              │"
    echo "│ 2. Click 'Build' workflow                    │"
    echo "│ 3. Click 'Run workflow' button               │"
    echo "│ 4. Wait for completion                       │"
    echo "│ 5. Download from 'Artifacts' or 'Releases'   │"
    echo "│                                              │"
    echo "└──────────────────────────────────────────────┘"
    echo
    
    if command -v flutter >/dev/null 2>&1; then
        echo "┌─ Method 3: Local Build (Flutter Available) ──┐"
        echo "│                                              │"
        echo "│ Run in terminal:                             │"
        echo "│ ./build.sh apk --flavor dev --release       │"
        echo "│                                              │"
        echo "│ Output: artifacts/boorusama-${version}-dev.apk │"
        echo "│                                              │"
        echo "└──────────────────────────────────────────────┘"
        echo
    fi
    
    print_warning "Note: Due to network restrictions, local Flutter installation"
    print_warning "      is not available. Use GitHub Actions (Methods 1 or 2)."
    echo
    
    print_info "📋 Build Features:"
    echo "  • Automated GitHub Actions workflows"
    echo "  • Release mode optimization"
    echo "  • Dev flavor configuration"
    echo "  • Artifact retention (30 days)"
    echo "  • Optional release publishing"
    echo
    
    print_info "📚 Additional Resources:"
    echo "  • Build validation: ./validate-dev-build.sh"
    echo "  • Complete guide: DEV_BUILD.md"
    echo "  • Build script: ./build.sh --help"
    echo
    
    print_status "Ready to generate APK! Use GitHub Actions workflows above."
}

# Main execution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    show_apk_generation_guide
fi