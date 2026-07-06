#!/usr/bin/env bash
# Fix file_picker's Android build.gradle to work with Flutter 3.44's Built-in Kotlin.
#
# file_picker v11 uses `buildscript { classpath "kotlin-gradle-plugin" }` and only
# applies `org.jetbrains.kotlin.android` when AGP < 9.  Flutter 3.44 ships AGP 9+
# and provides Built-in Kotlin, but the plugin's guard prevents Kotlin compilation.
#
# This patch removes the buildscript block and always applies the Kotlin plugin,
# which Flutter supplies on the buildscript classpath.
#
# Re-run after `flutter pub upgrade` if file_picker's version changes.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PUB_CACHE="${PUB_CACHE:-$HOME/.pub-cache}"

# Locate the file_picker android build.gradle
BUILD_GRADLE=$(find "$PUB_CACHE/hosted/pub.dev/file_picker-"*"/android/build.gradle" \
  2>/dev/null | head -1)

if [ -z "$BUILD_GRADLE" ]; then
  echo "ERROR: file_picker not found in pub cache. Run 'flutter pub get' first."
  exit 1
fi

CURRENT_HASH=$(md5sum "$BUILD_GRADLE" | cut -d' ' -f1)

# Check if already patched (look for absence of buildscript block)
if ! grep -q 'buildscript {' "$BUILD_GRADLE" 2>/dev/null; then
  echo "✓ file_picker already patched ($BUILD_GRADLE)"
  exit 0
fi

# Take a backup
cp "$BUILD_GRADLE" "$BUILD_GRADLE.bak"

# Write patched version
cat > "$BUILD_GRADLE" <<'PATCHED'
group 'com.mr.flutter.plugin.filepicker'
version '1.0-SNAPSHOT'

apply plugin: 'com.android.library'
apply plugin: 'org.jetbrains.kotlin.android'

android {
    compileSdk flutter.compileSdkVersion

    defaultConfig {
        minSdk 21
        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
        consumerProguardFiles 'proguard-rules.pro'
    }
    lintOptions {
        disable 'InvalidPackage'
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }
    
    dependencies {
        implementation 'androidx.core:core:1.15.0'
        implementation 'androidx.annotation:annotation:1.9.1'
        implementation "androidx.lifecycle:lifecycle-runtime:2.8.7"
        implementation "org.apache.tika:tika-core:3.2.3"
    }

    if (project.android.hasProperty("namespace")) {
        namespace 'com.mr.flutter.plugin.filepicker' 
    }
}
dependencies {
    implementation 'androidx.core:core-ktx:1.15.0'
}
PATCHED

echo "✓ Patched $BUILD_GRADLE"
echo "  Backup saved as ${BUILD_GRADLE}.bak"
echo ""
echo "Note: This patch is overwritten by 'flutter pub upgrade'. Run this script"
echo "again after upgrading dependencies."
