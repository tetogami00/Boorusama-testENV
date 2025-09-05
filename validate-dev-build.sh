#!/bin/bash
set -e

#==============================================================================
# Boorusama Dev Build Validation Script
#==============================================================================
# This script validates that the development environment is ready for building
# the Boorusama app. It checks dependencies, configurations, and build readiness.

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$SCRIPT_DIR"

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[ℹ]${NC} $1"
}

check_file_exists() {
    local file="$1"
    local description="$2"
    
    if [ -f "$file" ]; then
        print_status "$description found: $file"
        return 0
    else
        print_error "$description missing: $file"
        return 1
    fi
}

check_directory_exists() {
    local dir="$1"
    local description="$2"
    
    if [ -d "$dir" ]; then
        print_status "$description found: $dir"
        return 0
    else
        print_error "$description missing: $dir"
        return 1
    fi
}

check_flutter_installation() {
    print_info "Checking Flutter installation..."
    
    if command -v flutter >/dev/null 2>&1; then
        local flutter_version
        flutter_version=$(flutter --version | head -n1 | cut -d ' ' -f 2)
        print_status "Flutter installed: $flutter_version"
        
        # Check if Flutter is properly configured
        if flutter doctor --version >/dev/null 2>&1; then
            print_status "Flutter is properly configured"
            return 0
        else
            print_warning "Flutter found but may not be properly configured"
            print_info "Run 'flutter doctor' to check for issues"
            return 1
        fi
    else
        print_warning "Flutter not found in PATH"
        print_info "Install Flutter or use GitHub Actions for building"
        return 1
    fi
}

check_project_files() {
    print_info "Checking project files..."
    
    local files_ok=true
    
    # Check essential project files
    check_file_exists "$PROJECT_ROOT/pubspec.yaml" "pubspec.yaml" || files_ok=false
    check_file_exists "$PROJECT_ROOT/build.sh" "Build script" || files_ok=false
    check_file_exists "$PROJECT_ROOT/gen.sh" "Code generation script" || files_ok=false
    
    # Check Flutter app structure
    check_directory_exists "$PROJECT_ROOT/lib" "Source directory" || files_ok=false
    check_directory_exists "$PROJECT_ROOT/android" "Android configuration" || files_ok=false
    check_directory_exists "$PROJECT_ROOT/env" "Environment configs" || files_ok=false
    
    # Check flavor configurations
    check_file_exists "$PROJECT_ROOT/env/dev.json" "Dev flavor config" || files_ok=false
    check_file_exists "$PROJECT_ROOT/env/prod.json" "Prod flavor config" || files_ok=false
    
    # Check main entry points
    check_file_exists "$PROJECT_ROOT/lib/main.dart" "Main entry point" || files_ok=false
    
    if [ "$files_ok" = true ]; then
        print_status "All essential project files found"
        return 0
    else
        print_error "Some essential project files are missing"
        return 1
    fi
}

check_build_tools() {
    print_info "Checking build tools..."
    
    local tools_ok=true
    
    # Check if build.sh is executable
    if [ -x "$PROJECT_ROOT/build.sh" ]; then
        print_status "build.sh is executable"
    else
        print_warning "build.sh is not executable, making it executable..."
        chmod +x "$PROJECT_ROOT/build.sh"
        print_status "build.sh made executable"
    fi
    
    # Check if gen.sh is executable
    if [ -x "$PROJECT_ROOT/gen.sh" ]; then
        print_status "gen.sh is executable"
    else
        print_warning "gen.sh is not executable, making it executable..."
        chmod +x "$PROJECT_ROOT/gen.sh"
        print_status "gen.sh made executable"
    fi
    
    return 0
}

check_github_actions() {
    print_info "Checking GitHub Actions workflows..."
    
    local workflows_ok=true
    
    check_directory_exists "$PROJECT_ROOT/.github" "GitHub directory" || workflows_ok=false
    check_directory_exists "$PROJECT_ROOT/.github/workflows" "Workflows directory" || workflows_ok=false
    
    # Check for build workflows
    if [ -f "$PROJECT_ROOT/.github/workflows/main.yml" ]; then
        print_status "Main build workflow found"
    else
        print_warning "Main build workflow not found"
        workflows_ok=false
    fi
    
    if [ -f "$PROJECT_ROOT/.github/workflows/dev-build.yml" ]; then
        print_status "Dev build workflow found"
    else
        print_warning "Dev build workflow not found"
        workflows_ok=false
    fi
    
    if [ "$workflows_ok" = true ]; then
        print_status "GitHub Actions workflows are configured"
        return 0
    else
        print_warning "Some GitHub Actions workflows are missing"
        return 1
    fi
}

check_app_configuration() {
    print_info "Checking app configuration..."
    
    # Extract app info from pubspec.yaml
    if [ -f "$PROJECT_ROOT/pubspec.yaml" ]; then
        local app_name version
        app_name=$(head -n 1 "$PROJECT_ROOT/pubspec.yaml" | cut -d ' ' -f 2)
        version=$(head -n 5 "$PROJECT_ROOT/pubspec.yaml" | tail -n 1 | cut -d ' ' -f 2)
        
        print_status "App name: $app_name"
        print_status "Version: $version"
        
        # Check dev flavor configuration
        if [ -f "$PROJECT_ROOT/env/dev.json" ]; then
            local dev_app_name
            dev_app_name=$(grep '"APP_NAME"' "$PROJECT_ROOT/env/dev.json" | cut -d '"' -f 4)
            print_status "Dev app name: $dev_app_name"
        fi
        
        return 0
    else
        print_error "Cannot read app configuration from pubspec.yaml"
        return 1
    fi
}

show_build_options() {
    echo
    print_info "=== BUILD OPTIONS ==="
    echo
    print_info "Local Build (if Flutter is installed):"
    echo "  ./build.sh apk --flavor dev --release"
    echo
    print_info "GitHub Actions Build:"
    echo "  1. Go to GitHub repository"
    echo "  2. Click 'Actions' tab"
    echo "  3. Select 'Dev Build' workflow"
    echo "  4. Click 'Run workflow'"
    echo "  5. Download APK from artifacts"
    echo
    print_info "Main Build Workflow:"
    echo "  1. Go to GitHub repository"
    echo "  2. Click 'Actions' tab"
    echo "  3. Select 'Build' workflow"
    echo "  4. Click 'Run workflow'"
    echo "  5. Download APK from artifacts or releases"
    echo
}

main() {
    echo "=== Boorusama Dev Build Validation ==="
    echo
    
    local validation_passed=true
    
    # Run all validation checks
    check_project_files || validation_passed=false
    echo
    
    check_build_tools || validation_passed=false
    echo
    
    check_app_configuration || validation_passed=false
    echo
    
    check_github_actions || validation_passed=false
    echo
    
    check_flutter_installation || validation_passed=false
    echo
    
    # Show results
    if [ "$validation_passed" = true ]; then
        print_status "=== VALIDATION PASSED ==="
        print_status "Development environment is ready for building!"
        show_build_options
        exit 0
    else
        print_error "=== VALIDATION FAILED ==="
        print_error "Some issues were found in the development environment."
        print_info "Please fix the issues above before building."
        show_build_options
        exit 1
    fi
}

# Run main function if script is executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi