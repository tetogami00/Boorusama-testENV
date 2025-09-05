# Boorusama Development Build Guide

This guide provides comprehensive instructions for building Boorusama in development mode using various methods.

## Quick Start

```bash
# Validate build readiness
./validate-dev-build.sh

# Build locally (if Flutter is installed)
./build.sh apk --flavor dev --release

# Or use GitHub Actions for automated builds
```

## Prerequisites

### For Local Development
- **Flutter SDK**: Version 3.24.5 or later
- **Java JDK**: Version 17 (for Android builds)
- **Android SDK**: With build tools (automatically handled by Flutter)
- **Git**: For version control

### For GitHub Actions
- **Repository access**: Push permissions to trigger workflows
- **GitHub Actions**: Enabled in repository settings

## Build Methods

### 1. GitHub Actions (Recommended)

The easiest way to build without local Flutter setup:

#### Using Dev Build Workflow
1. Go to your GitHub repository
2. Click the **Actions** tab
3. Select **"Dev Build"** workflow
4. Click **"Run workflow"** button
5. Choose release mode (recommended: `true`)
6. Click **"Run workflow"** to start
7. Wait for build completion (5-10 minutes)
8. Download APK from **Artifacts** section

#### Using Main Build Workflow
1. Go to your GitHub repository
2. Click the **Actions** tab
3. Select **"Build"** workflow
4. Click **"Run workflow"** button
5. Wait for build completion
6. Download APK from **Artifacts** or **Releases**

### 2. Local Development Build

If you have Flutter installed locally:

```bash
# Validate environment first
./validate-dev-build.sh

# Quick dev build (debug mode)
./build.sh apk --flavor dev --debug

# Optimized dev build (release mode) 
./build.sh apk --flavor dev --release

# FOSS build (without proprietary dependencies)
./build.sh apk --flavor dev --release --foss
```

### 3. Manual Flutter Commands

For advanced users who prefer direct Flutter commands:

```bash
# Generate required code first
./gen.sh

# Build debug APK
flutter build apk --flavor dev --debug --dart-define-from-file env/dev.json

# Build release APK
flutter build apk --flavor dev --release --dart-define-from-file env/dev.json
```

## Build Outputs

### Dev Flavor Configuration
- **App Name**: "Boorusama Dev"
- **Package**: Different from production
- **Target**: `lib/main.dart`
- **Environment**: Development settings from `env/dev.json`

### Output Locations
- **Local builds**: `artifacts/boorusama-{version}-dev.apk`
- **GitHub Actions**: Available in workflow artifacts
- **Releases**: Tagged as `dev-v{version}` for dev builds

## Build Flavors

### Development (`dev`)
```bash
./build.sh apk --flavor dev --release
```
- App name: "Boorusama Dev"
- Development features enabled
- Separate package ID for side-by-side installation
- Debug-friendly configuration

### Production (`prod`)
```bash
./build.sh apk --flavor prod --release
```
- App name: "Boorusama"
- Production-ready configuration
- Requires additional API keys in `.env` file
- Store-ready build

## Environment Setup

### Local Flutter Installation

1. **Install Flutter**:
   ```bash
   # Download Flutter 3.24.5
   git clone https://github.com/flutter/flutter.git -b stable
   export PATH="$PATH:`pwd`/flutter/bin"
   ```

2. **Verify Installation**:
   ```bash
   flutter doctor
   ```

3. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

### Environment Variables

Create `.env` file for production builds:
```env
REVENUECAT_GOOGLE_API_KEY=your_google_api_key_here
REVENUECAT_APPLE_API_KEY=your_apple_api_key_here
```

## Troubleshooting

### Common Issues

#### Flutter Not Found
```bash
# Error: flutter: command not found
# Solution: Install Flutter or use GitHub Actions
```

#### Build Failures
```bash
# Run validation first
./validate-dev-build.sh

# Clean and rebuild
flutter clean
flutter pub get
./gen.sh
./build.sh apk --flavor dev --release
```

#### Permission Denied
```bash
# Make scripts executable
chmod +x build.sh
chmod +x gen.sh
chmod +x validate-dev-build.sh
```

#### Missing Dependencies
```bash
# Install missing Dart/Flutter dependencies
flutter pub get

# Generate required code
./gen.sh
```

### GitHub Actions Issues

#### Workflow Not Triggering
- Check repository permissions
- Ensure Actions are enabled in repository settings
- Verify workflow file syntax

#### Build Timeouts
- GitHub Actions have time limits
- Large builds may need optimization
- Consider using caching (already configured)

#### Artifact Download Issues
- Artifacts expire after 30 days
- Use releases for permanent storage
- Check download permissions

### Advanced Troubleshooting

#### Debug Build Issues
```bash
# Enable verbose output
./build.sh apk --flavor dev --debug --verbose

# Check Flutter diagnostics
flutter doctor -v
```

#### Clean Environment
```bash
# Complete clean rebuild
flutter clean
rm -rf build/
flutter pub get
./gen.sh
./build.sh apk --flavor dev --release
```

## Build Validation

The `validate-dev-build.sh` script checks:
- ✅ Project file structure
- ✅ Build tool availability
- ✅ Flutter installation (if local)
- ✅ Environment configuration
- ✅ GitHub Actions setup

Run validation before building:
```bash
./validate-dev-build.sh
```

## Performance Notes

### Build Times
- **Local builds**: 3-8 minutes (depending on hardware)
- **GitHub Actions**: 5-15 minutes (including setup)
- **Clean builds**: Longer due to dependency resolution

### Optimization Tips
- Use `--release` mode for distribution
- Enable caching in CI/CD (already configured)
- Avoid unnecessary clean builds
- Use incremental builds for development

## Continuous Integration

### Automated Builds
- **Push to main**: Triggers main build workflow
- **Manual trigger**: Use workflow dispatch
- **Pull requests**: Can trigger validation builds

### Artifact Management
- **Development builds**: 30-day retention
- **Release builds**: Permanent via GitHub releases
- **Multiple formats**: APK, AAB (App Bundle) support

## Security Notes

### API Keys
- Store sensitive keys in `.env` file
- Never commit API keys to repository
- Use GitHub Secrets for CI/CD builds

### Build Integrity
- GitHub Actions provide build logs
- Reproducible builds via version pinning
- Checksum validation available

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Android Build Guide](https://flutter.dev/docs/deployment/android)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## Support

For build issues:
1. Run `./validate-dev-build.sh` first
2. Check GitHub Actions logs
3. Review Flutter doctor output
4. Check this documentation

---

**Last Updated**: Generated automatically with dev build setup