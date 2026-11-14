#!/data/data/com.termux/files/usr/bin/bash
# Optional Android APK build toolchain. Termux compatibility is device/repository dependent.
ANDROID_SDK_DIR="${ANDROID_SDK_DIR:-$HOME/android-sdk}"
ANDROID_PLATFORM="${ANDROID_PLATFORM:-android-35}"
ANDROID_BUILD_TOOLS="${ANDROID_BUILD_TOOLS:-35.0.0}"
ANDROID_GRADLE_VERSION="${ANDROID_GRADLE_VERSION:-8.9}"
ANDROID_AGP_VERSION="${ANDROID_AGP_VERSION:-8.7.3}"
ANDROID_KOTLIN_VERSION="${ANDROID_KOTLIN_VERSION:-2.0.21}"
ANDROID_WRAPPER_HOME="$HOME/.local/share/inyogeshwar-termux-setup/wrapper"

_android_backup() { [[ -f "$1" ]] && cp -p "$1" "$1.inyogeshwar-backup-$(date +%Y%m%d-%H%M%S)"; }
_android_env_block() {
  local file="$1" marker='# >>> InYogeshwar Android Build Environment >>>'
  touch "$file"; grep -Fq "$marker" "$file" && return 0; _android_backup "$file"
  cat >> "$file" <<'ENV_BLOCK'

# >>> InYogeshwar Android Build Environment >>>
export JAVA_HOME="$PREFIX/lib/jvm/java-17-openjdk"
export ANDROID_HOME="$HOME/android-sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
# <<< InYogeshwar Android Build Environment <<<
ENV_BLOCK
}
_android_gradle_prop() {
  local key="$1" value="$2" file="$HOME/.gradle/gradle.properties"
  mkdir -p "$HOME/.gradle"; touch "$file"
  if grep -q "^${key}=" "$file"; then sed -i "s|^${key}=.*|${key}=${value}|" "$file"
  else printf '%s=%s\n' "$key" "$value" >> "$file"; fi
}

android_build_install_packages() {
  show_banner; info 'Installing Java 17, Gradle and Termux-native Android tools...'
  pkg update -y || { err 'pkg update failed.'; return 1; }
  pkg install -y openjdk-17 gradle aapt aapt2 apksigner unzip wget curl || {
    err 'A package is unavailable in the configured Termux repository.'
    info 'Check package names with: pkg search aapt / pkg search apksigner / pkg search zipalign'; return 1;
  }
  export JAVA_HOME="$PREFIX/lib/jvm/java-17-openjdk"
  [[ -x "$JAVA_HOME/bin/java" ]] || { err 'Java 17 binary not found.'; return 1; }
  _android_gradle_prop org.gradle.jvmargs '-Xmx1536m -Dfile.encoding=UTF-8'
  _android_gradle_prop org.gradle.vfs.watch false
  _android_gradle_prop kotlin.daemon.jvmargs '-Xmx768m'
  command -v aapt2 >/dev/null && _android_gradle_prop android.aapt2FromMavenOverride "$PREFIX/bin/aapt2"
  _android_env_block "$HOME/.bashrc"
  [[ ! -f "$HOME/.zshrc" ]] || _android_env_block "$HOME/.zshrc"
  _android_env_block "$HOME/.profile"
  java -version 2>&1 | tee -a "$LOG_FILE"
  ok 'Java / Gradle / native tools installed; shell environment configured.'
}

android_build_install_sdk() {
  show_banner
  local sdkmanager="$ANDROID_SDK_DIR/cmdline-tools/latest/bin/sdkmanager"
  local cache="$HOME/.cache/inyogeshwar-termux-setup" archive="$HOME/.cache/inyogeshwar-termux-setup/cmdline.zip"
  mkdir -p "$ANDROID_SDK_DIR/cmdline-tools" "$cache"
  if [[ ! -x "$sdkmanager" ]]; then
    info 'Downloading Google Android command-line tools...'
    curl -fL --retry 2 'https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip' -o "$archive" || { err 'Command-line tools download failed.'; return 1; }
    local unpack="$cache/unpack"
    rm -rf "$unpack"; mkdir -p "$unpack"
    unzip -q "$archive" -d "$unpack" || { err 'Invalid command-line tools archive.'; return 1; }
    [[ -d "$unpack/cmdline-tools" ]] || { err 'Unexpected archive layout.'; return 1; }
    rm -rf "$ANDROID_SDK_DIR/cmdline-tools/latest"
    mv "$unpack/cmdline-tools" "$ANDROID_SDK_DIR/cmdline-tools/latest"; rm -rf "$unpack"
  fi
  [[ -x "$sdkmanager" ]] || { err 'sdkmanager missing after extraction.'; return 1; }
  export JAVA_HOME="$PREFIX/lib/jvm/java-17-openjdk" ANDROID_HOME="$ANDROID_SDK_DIR" ANDROID_SDK_ROOT="$ANDROID_SDK_DIR"
  "$sdkmanager" --version >/dev/null 2>&1 || { err 'sdkmanager cannot run in this Termux environment; check Java/runtime compatibility.'; return 1; }
  yes | "$sdkmanager" --sdk_root="$ANDROID_SDK_DIR" --licenses >/dev/null 2>&1 || warn 'SDK license command returned non-zero.'
  local log_file="$LOG_DIR/sdkmanager-install.log"
  info "Installing $ANDROID_PLATFORM and Build Tools $ANDROID_BUILD_TOOLS..."
  "$sdkmanager" --sdk_root="$ANDROID_SDK_DIR" "platforms;$ANDROID_PLATFORM" "build-tools;$ANDROID_BUILD_TOOLS" >"$log_file" 2>&1 || {
    err "sdkmanager failed; see $log_file"; tail -n 25 "$log_file"; return 1;
  }
  [[ -f "$ANDROID_SDK_DIR/platforms/$ANDROID_PLATFORM/android.jar" ]] && ok "$ANDROID_PLATFORM android.jar found." || warn 'android.jar missing despite sdkmanager exit success.'
  # Google build-tools are desktop Linux binaries. Only link native Termux tools where safe.
  local tool bt="$ANDROID_SDK_DIR/build-tools/$ANDROID_BUILD_TOOLS"
  for tool in aapt aapt2 aidl zipalign apksigner; do
    if command -v "$tool" >/dev/null 2>&1 && { [[ ! -e "$bt/$tool" ]] || [[ -L "$bt/$tool" ]]; }; then
      mkdir -p "$bt"; ln -sf "$(command -v "$tool")" "$bt/$tool"
    elif ! command -v "$tool" >/dev/null 2>&1; then warn "Native Termux $tool not found; left SDK file untouched."; fi
  done
  ok 'SDK installation attempt completed; validate toolchain before building.'
}

android_build_create_wrapper() {
  show_banner; command -v gradle >/dev/null || { err 'Install Gradle first.'; return 1; }
  local temp="$TMPDIR/inyogeshwar-wrapper-$$"
  mkdir -p "$temp" "$ANDROID_WRAPPER_HOME"
  (cd "$temp" && touch settings.gradle && gradle -q wrapper --gradle-version "$ANDROID_GRADLE_VERSION") || {
    rm -rf "$temp"; err 'Gradle wrapper generation failed.'; return 1;
  }
  cp -r "$temp/gradlew" "$temp/gradle" "$ANDROID_WRAPPER_HOME/"; chmod +x "$ANDROID_WRAPPER_HOME/gradlew"; rm -rf "$temp"
  cat > "$PREFIX/bin/addwrapper" <<'ADDWRAPPER'
#!/data/data/com.termux/files/usr/bin/bash
set -e
src="$HOME/.local/share/inyogeshwar-termux-setup/wrapper"
[[ -f "$src/gradlew" && -d "$src/gradle" ]] || { echo 'Wrapper template missing; generate it from the menu first.'; exit 1; }
[[ ! -e ./gradlew && ! -e ./gradle ]] || { echo 'Wrapper already exists here; refusing to overwrite.'; exit 1; }
cp -r "$src/gradlew" "$src/gradle" .; chmod +x ./gradlew
echo 'Wrapper added. Build with: ./gradlew assembleDebug'
ADDWRAPPER
  chmod +x "$PREFIX/bin/addwrapper"; ok 'Wrapper template ready. Run addwrapper inside an Android project.'
}

android_build_test_apk() {
  show_banner
  local app="$HOME/inyogeshwar-android-build-test"
  [[ ! -e "$app" ]] || { err "Refusing to overwrite existing directory: $app"; return 1; }
  [[ -f "$ANDROID_SDK_DIR/platforms/$ANDROID_PLATFORM/android.jar" ]] || { err 'Install Android SDK platform first.'; return 1; }
  mkdir -p "$app/app/src/main/java/com/inyogeshwar/buildtest"
  cat > "$app/settings.gradle" <<'SETTINGS'
pluginManagement { repositories { google(); mavenCentral(); gradlePluginPortal() } }
dependencyResolutionManagement { repositories { google(); mavenCentral() } }
rootProject.name = 'InYogeshwarBuildTest'
include(':app')
SETTINGS
  cat > "$app/build.gradle" <<APP_ROOT
plugins {
  id 'com.android.application' version '$ANDROID_AGP_VERSION' apply false
  id 'org.jetbrains.kotlin.android' version '$ANDROID_KOTLIN_VERSION' apply false
}
APP_ROOT
  cat > "$app/app/build.gradle" <<'APP_BUILD'
plugins { id 'com.android.application'; id 'org.jetbrains.kotlin.android' }
android {
  namespace 'com.inyogeshwar.buildtest'
  compileSdk 35
  defaultConfig { applicationId 'com.inyogeshwar.buildtest'; minSdk 24; targetSdk 35; versionCode 1; versionName '1.0' }
  compileOptions { sourceCompatibility JavaVersion.VERSION_17; targetCompatibility JavaVersion.VERSION_17 }
  kotlinOptions { jvmTarget = '17' }
}
APP_BUILD
  cat > "$app/app/src/main/AndroidManifest.xml" <<'MANIFEST'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <application android:label="InYogeshwar Build Test" android:theme="@android:style/Theme.Material">
    <activity android:name=".MainActivity" android:exported="true"><intent-filter><action android:name="android.intent.action.MAIN"/><category android:name="android.intent.category.LAUNCHER"/></intent-filter></activity>
  </application>
</manifest>
MANIFEST
  cat > "$app/app/src/main/java/com/inyogeshwar/buildtest/MainActivity.kt" <<'KOTLIN'
package com.inyogeshwar.buildtest
import android.app.Activity
import android.os.Bundle
import android.view.Gravity
import android.widget.TextView
class MainActivity : Activity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContentView(TextView(this).apply { text = "Built with Termux"; textSize = 22f; gravity = Gravity.CENTER })
  }
}
KOTLIN
  android_build_create_wrapper || return 1
  cp -r "$ANDROID_WRAPPER_HOME/gradlew" "$ANDROID_WRAPPER_HOME/gradle" "$app/"; chmod +x "$app/gradlew"
  if (cd "$app" && ./gradlew assembleDebug --no-daemon 2>&1 | tee -a "$LOG_FILE"); then
    local apk="$app/app/build/outputs/apk/debug/app-debug.apk"
    [[ -f "$apk" ]] || { err 'APK file not found after Gradle success.'; return 1; }
    ok "Test APK built: $apk"
    if [[ -d "$HOME/storage/downloads" ]]; then cp "$apk" "$HOME/storage/downloads/InYogeshwar-Build-Test.apk" && ok 'Copied to Download folder.'
    else warn 'Storage not mounted. Run termux-setup-storage to enable Download copy.'; fi
  else err 'Test APK build failed; inspect Gradle output and setup log.'; return 1; fi
}

android_build_diagnostics() {
  show_banner; printf '%b\n' "${WHITE}ANDROID BUILD DIAGNOSTICS${RESET}"
  printf 'SDK: %s | Platform: %s | Build tools: %s\n' "$ANDROID_SDK_DIR" "$ANDROID_PLATFORM" "$ANDROID_BUILD_TOOLS"
  printf 'Architecture: %s\n' "$(uname -m)"
  local bin
  for bin in java javac gradle aapt aapt2 aidl zipalign apksigner; do
    if command -v "$bin" >/dev/null 2>&1; then printf '%b %s: %s\n' "${GREEN}✔${RESET}" "$bin" "$(command -v "$bin")"
    else printf '%b %s: not found\n' "${YELLOW}•${RESET}" "$bin"; fi
  done
  [[ -f "$ANDROID_SDK_DIR/platforms/$ANDROID_PLATFORM/android.jar" ]] && ok 'android.jar present' || warn 'android.jar missing'
  [[ -x "$ANDROID_SDK_DIR/cmdline-tools/latest/bin/sdkmanager" ]] && ok 'sdkmanager present' || warn 'sdkmanager missing'
  printf 'Log: %s\n' "$LOG_FILE"
}

android_build_menu() {
  while true; do
    show_banner; printf '%b\n' "${WHITE}ANDROID APK BUILD SETUP${RESET}"; line
    printf '%b\n' "${CYAN}1)${RESET} Install Java / Gradle / native build tools"
    printf '%b\n' "${CYAN}2)${RESET} Install Android SDK Platform + Build Tools"
    printf '%b\n' "${CYAN}3)${RESET} Generate Gradle wrapper + addwrapper"
    printf '%b\n' "${CYAN}4)${RESET} Create and build a safe test APK"
    printf '%b\n' "${CYAN}5)${RESET} Android build diagnostics"
    printf '%b\n' "${CYAN}0)${RESET} Back"; line
    read -r -p 'Select an option: ' choice
    case "$choice" in
      1) android_build_install_packages; pause ;;
      2) android_build_install_sdk; pause ;;
      3) android_build_create_wrapper; pause ;;
      4) android_build_test_apk; pause ;;
      5) android_build_diagnostics; pause ;;
      0) return 0 ;;
      *) warn 'Invalid option.'; sleep 1 ;;
    esac
  done
}
