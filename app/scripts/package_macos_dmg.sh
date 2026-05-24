#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="${APP_NAME:-Bumblebee}"
BUNDLE_ID="${BUNDLE_ID:-bumblebee.drmhse.com}"
TEAM_ID="${TEAM_ID:-SJRM8TVZYF}"
SIGN_IDENTITY="${SIGN_IDENTITY:-Developer ID Application: Mike Chumba (SJRM8TVZYF)}"
NOTARY_PROFILE="${NOTARY_PROFILE:-bumblebee-notary}"
SECRET_FILE="${SECRET_FILE:-$ROOT/.app_password_and_email.txt}"
DIST_DIR="${DIST_DIR:-$ROOT/dist/macos}"
SKIP_NOTARIZE="${SKIP_NOTARIZE:-0}"
if [[ -n "${BUMP_VERSION:-}" ]]; then
  "$ROOT/scripts/bump_version.sh" "$BUMP_VERSION" >&2
fi
VERSION="$("$ROOT"/scripts/read_pubspec_version.sh)"

read_secret() {
  local key="$1"
  perl -0ne "if (/(?:^|\\s)\\Q$key\\E\\s*:\\s*([^\\s]+)/i) { print \$1; exit }" "$SECRET_FILE"
}

store_notary_credentials() {
  if [[ ! -f "$SECRET_FILE" ]]; then
    echo "Missing secret file: $SECRET_FILE" >&2
    exit 1
  fi
  local apple_id password
  apple_id="$(read_secret email)"
  password="$(read_secret password)"
  if [[ -z "$apple_id" || -z "$password" ]]; then
    echo "Secret file must contain 'email:' and 'password:' entries." >&2
    exit 1
  fi
  xcrun notarytool store-credentials "$NOTARY_PROFILE" \
    --apple-id "$apple_id" \
    --team-id "$TEAM_ID" \
    --password "$password"
}

build_arch() {
  local arch="$1"
  local derived="$ROOT/build/macos-$arch"
  xcodebuild \
    -workspace "$ROOT/macos/Runner.xcworkspace" \
    -scheme Runner \
    -configuration Release \
    -destination "platform=macOS,arch=$arch" \
    -derivedDataPath "$derived" \
    ARCHS="$arch" \
    ONLY_ACTIVE_ARCH=NO \
    DEVELOPMENT_TEAM="$TEAM_ID" \
    CODE_SIGN_STYLE=Manual \
    CODE_SIGN_IDENTITY="$SIGN_IDENTITY" \
    ENABLE_HARDENED_RUNTIME=YES \
    CODE_SIGN_INJECT_BASE_ENTITLEMENTS=NO \
    PRODUCT_BUNDLE_IDENTIFIER="$BUNDLE_ID" \
    clean build >&2
  echo "$derived/Build/Products/Release/$APP_NAME.app"
}

prune_bundled_helpers() {
  local app_path="$1"
  local keep="$2"
  local bin_dir="$app_path/Contents/Frameworks/App.framework/Versions/A/Resources/flutter_assets/assets/bin"
  if [[ ! -d "$bin_dir" ]]; then
    return
  fi
  find "$bin_dir" -mindepth 1 -maxdepth 1 -type d ! -name "$keep" -print0 |
    while IFS= read -r -d '' dir; do
      rm -rf "$dir"
    done
}

resign_app() {
  local app_path="$1"
  find "$app_path/Contents" -type f -perm -111 \
    ! -path '*/_CodeSignature/*' \
    ! -name '*.plist' \
    -print0 |
    while IFS= read -r -d '' file; do
      if file "$file" | grep -Eq 'Mach-O|executable'; then
        codesign --force --timestamp --options runtime \
          --sign "$SIGN_IDENTITY" "$file" 2>/dev/null || true
      fi
    done
  find "$app_path/Contents/Frameworks" -maxdepth 1 -name '*.framework' -print0 2>/dev/null |
    while IFS= read -r -d '' framework; do
      codesign --force --timestamp --options runtime \
        --sign "$SIGN_IDENTITY" "$framework"
    done
  codesign --force --timestamp --options runtime \
    --entitlements "$ROOT/macos/Runner/Release.entitlements" \
    --sign "$SIGN_IDENTITY" "$app_path"
}

make_dmg() {
  local app_path="$1"
  local label="$2"
  local stage="$DIST_DIR/stage-$label"
  local dmg="$DIST_DIR/$APP_NAME-$VERSION-$label.dmg"
  rm -rf "$stage" "$dmg"
  mkdir -p "$stage"
  ditto "$app_path" "$stage/$APP_NAME.app"
  ditto "$ROOT/LICENSE" "$stage/LICENSE.txt"
  ditto "$ROOT/NOTICE" "$stage/NOTICE.txt"
  ln -s /Applications "$stage/Applications"
  hdiutil create \
    -volname "$APP_NAME" \
    -srcfolder "$stage" \
    -ov \
    -format UDZO \
    "$dmg" >&2
  codesign --force --timestamp --sign "$SIGN_IDENTITY" "$dmg" >&2
  echo "$dmg"
}

notarize_and_verify() {
  local dmg="$1"
  xcrun notarytool submit "$dmg" \
    --keychain-profile "$NOTARY_PROFILE" \
    --wait
  xcrun stapler staple "$dmg"
  xcrun stapler validate "$dmg"
  spctl -a -t open --context context:primary-signature -v "$dmg"
}

verify_app() {
  local app_path="$1"
  codesign --verify --deep --strict --verbose=2 "$app_path"
}

main() {
  cd "$ROOT"
  mkdir -p "$DIST_DIR"
  if [[ "$SKIP_NOTARIZE" != "1" ]]; then
    store_notary_credentials
  fi
  flutter pub get
  flutter build macos --release --config-only

  local app_arm dmg_arm app_x64 dmg_x64
  app_arm="$(build_arch arm64)"
  prune_bundled_helpers "$app_arm" macos-arm64
  resign_app "$app_arm"
  verify_app "$app_arm"
  dmg_arm="$(make_dmg "$app_arm" arm64)"
  if [[ "$SKIP_NOTARIZE" != "1" ]]; then
    notarize_and_verify "$dmg_arm"
  fi

  app_x64="$(build_arch x86_64)"
  prune_bundled_helpers "$app_x64" macos-x64
  resign_app "$app_x64"
  verify_app "$app_x64"
  dmg_x64="$(make_dmg "$app_x64" x64)"
  if [[ "$SKIP_NOTARIZE" != "1" ]]; then
    notarize_and_verify "$dmg_x64"
  fi

  echo "Packaged:"
  echo "$dmg_arm"
  echo "$dmg_x64"
}

main "$@"
