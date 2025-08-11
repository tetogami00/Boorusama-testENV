# Boorusama Flutter Development Guide

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

Boorusama is a cross-platform Flutter mobile application for browsing booru imageboards. It supports Android, iOS, macOS, Windows, and Linux platforms with both regular and FOSS (Free and Open Source Software) build variants.

### Prerequisites and Environment Setup

**CRITICAL**: Set timeouts to 60+ minutes for build commands and 30+ minutes for test commands. NEVER CANCEL long-running operations.

**Required Dependencies:**
- Install Flutter SDK 3.32.8 stable (exact version required)
- Install Git (required for Flutter)
- Install Java 17 (for Android builds)
- Install curl, unzip, xz-utils, zip, libglu1-mesa

**Flutter Installation:**
```bash
# Install prerequisites
sudo apt update && sudo apt install -y curl git unzip xz-utils zip libglu1-mesa

# Download and install Flutter 3.32.8 (Linux)
cd /tmp
git clone -b 3.32.8 --depth 1 https://github.com/flutter/flutter.git
export PATH="/tmp/flutter/bin:$PATH"

# Verify installation - requires internet connectivity
flutter doctor
```

**NETWORK REQUIREMENTS**: Flutter setup requires internet connectivity to download Dart SDK and dependencies. In restricted networks, Flutter installation may fail with "corrupt download" errors.

### Bootstrap and Build Process

**NEVER CANCEL builds or tests - they can take 45+ minutes to complete.**

```bash
# Navigate to project root
cd /path/to/Boorusama

# Install dependencies - NEVER CANCEL (5-15 minutes)
flutter pub get

# Generate code - NEVER CANCEL (2-5 minutes)
./gen.sh

# Build APK for development - NEVER CANCEL (15-45 minutes, timeout: 60+ minutes)
./build.sh apk --flavor dev

# Build production AAB - NEVER CANCEL (20-50 minutes, timeout: 60+ minutes)
./build.sh aab --flavor prod

# Build FOSS version APK - NEVER CANCEL (15-45 minutes, timeout: 60+ minutes)
./build.sh apk --flavor dev --foss
```

### Code Generation and Dependencies

**Always run code generation after making changes to certain files:**
```bash
# Run all code generation scripts - NEVER CANCEL (2-5 minutes)
./gen.sh

# Individual code generation (if gen.sh fails):
cd packages/i18n && dart run slang
cd packages/i18n && dart run tools/generate_language.dart
cd packages/booru_clients && dart run tools/generate_config.dart
```

### Testing

**NEVER CANCEL test runs - they can take 15-30 minutes.**
```bash
# Run all tests - NEVER CANCEL (15-30 minutes, timeout: 45+ minutes)
flutter test

# Run specific test file
flutter test test/specific_test.dart

# Run tests with coverage
flutter test --coverage
```

### Linting and Code Quality

**Always run these before committing or CI will fail:**
```bash
# Lint the code
flutter analyze

# Format the code
flutter format .

# Sort imports (custom script)
./sort-import.sh
```

### Build Variants and Flavors

The project supports multiple build configurations:

**Build Script Help:**
```bash
# View all build options
./build.sh apk --help
```

**Flavors:**
- `dev`: Development build with debug features
- `prod`: Production build for app stores

**Build Types:**
- Regular: Includes all features (Google Play, RevenueCat, etc.)
- FOSS: Strips proprietary dependencies (use `--foss` flag)

**Platform Targets:**
- `apk`: Android APK
- `aab`: Android App Bundle 
- `ipa`: iOS app (macOS only)
- `dmg`: macOS disk image (macOS only)
- `windows`: Windows executable (Windows only)
- `linux`: Linux executable (Linux only)

### Environment Configuration

**Required environment files:**
- `.env`: Contains API keys (see `.env.example`)
- `env/dev.json`: Development configuration
- `env/prod.json`: Production configuration

**Production builds require API keys in .env:**
```bash
REVENUECAT_GOOGLE_API_KEY=your_key_here  # For Android prod builds
REVENUECAT_APPLE_API_KEY=your_key_here   # For iOS prod builds
```

### Running the Application

**Development mode:**
```bash
# Hot reload development (default device)
flutter run --flavor dev

# Run on specific device
flutter run --flavor dev -d device_id

# Run in release mode
flutter run --flavor dev --release
```

**MANUAL VALIDATION SCENARIOS**: After making changes, always test these core workflows:
1. Launch the app and navigate to different booru sources
2. Search for images using tags
3. View and interact with image details
4. Test download functionality (if applicable)
5. Verify settings and preferences work correctly

### Common Commands and Timing Expectations

**Build Times (NEVER CANCEL - use 60+ minute timeouts):**
- `flutter pub get`: 5-15 minutes
- `./gen.sh`: 2-5 minutes  
- `./build.sh apk`: 15-45 minutes
- `./build.sh aab`: 20-50 minutes
- `flutter test`: 15-30 minutes
- `flutter analyze`: 1-5 minutes

**Common Issues:**
- Flutter setup fails with network errors: requires internet connectivity
- Build fails with missing API keys: check `.env` file for prod builds
- Code generation fails: ensure all packages are properly installed
- FOSS build excludes dependencies: `purchases_flutter`, `rate_my_app`, `google_api_availability`

## Project Structure

**Key directories:**
- `lib/`: Main application code
  - `lib/main.dart`: Regular app entry point
  - `lib/main_foss.dart`: FOSS variant entry point
  - `lib/boorus/`: Booru-specific implementations
  - `lib/core/`: Core application logic
  - `lib/foundation/`: Shared utilities and foundations
- `packages/`: Workspace packages (10 local packages)
  - `packages/foundation/`: Core building blocks
  - `packages/booru_clients/`: API clients for different boorus
  - `packages/i18n/`: Internationalization
- `test/`: Test files organized by feature
- `android/`, `ios/`, `macos/`, `windows/`, `linux/`: Platform-specific code
- `assets/`: Images, animations, configuration files

**Important files to check after making changes:**
- Always run `./gen.sh` after modifying translation files
- Always run `flutter analyze` before committing
- Check `analysis_options.yaml` for linting rules
- Review `CONTRIBUTING.md` for commit message format

**Workspace Configuration:**
The project uses Flutter workspace feature with 10 local packages. Dependencies are managed at both root and package levels.

## Validation and CI

**Pre-commit checklist:**
1. Run `./gen.sh` for code generation
2. Run `flutter analyze` for linting
3. Run `flutter format .` for formatting  
4. Run `./sort-import.sh` for import sorting
5. Run `flutter test` for testing
6. Build and test the specific platform you're targeting

**CI Workflows (`.github/workflows/`):**
- `main.yml`: Main build pipeline (uses macOS runner, builds APK)
- `ios.yml`: Alternative iOS build pipeline (uses Ubuntu runner)

The CI expects these to pass or builds will fail. Always validate locally first.

## Troubleshooting

**Network Connectivity Issues:**
Flutter requires internet access for initial setup and dependency downloads. In restricted environments, you may encounter:
- Dart SDK download failures
- Package resolution errors
- Build tool download issues

**Build Failures:**
- Missing API keys: Check `.env` file configuration
- Flutter version mismatch: Ensure exact version 3.32.8
- Platform tools missing: Install platform-specific SDKs
- Timeout errors: NEVER cancel builds, wait for completion

**Code Generation Failures:**
- Run individual generation commands if `./gen.sh` fails
- Check that all workspace packages are properly configured
- Ensure Dart tools are available and up to date

This guide provides the essential commands and workflows needed to work effectively with the Boorusama codebase. Always validate changes thoroughly and never cancel long-running build operations.