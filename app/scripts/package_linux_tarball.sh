#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="${APP_NAME:-Bumblebee}"
DIST_DIR="${DIST_DIR:-$ROOT/dist/linux}"

if [[ -n "${BUMP_VERSION:-}" ]]; then
  "$ROOT/scripts/bump_version.sh" "$BUMP_VERSION" >&2
fi

VERSION="$("$ROOT"/scripts/read_pubspec_version.sh)"
BUNDLE_DIR="$ROOT/build/linux/x64/release/bundle"
STAGE="$DIST_DIR/stage-linux-x64"
ARCHIVE="$DIST_DIR/$APP_NAME-$VERSION-linux-x64.tar.gz"

prune_bundled_helpers() {
  local keep="linux-x64"
  local bin_dir="$STAGE/$APP_NAME/data/flutter_assets/assets/bin"
  if [[ ! -d "$bin_dir" ]]; then
    return
  fi
  find "$bin_dir" -mindepth 1 -maxdepth 1 -type d ! -name "$keep" -print0 |
    while IFS= read -r -d '' dir; do
      rm -rf "$dir"
    done
}

main() {
  cd "$ROOT"
  flutter pub get
  flutter build linux --release

  rm -rf "$STAGE" "$ARCHIVE"
  mkdir -p "$STAGE"
  cp -R "$BUNDLE_DIR" "$STAGE/$APP_NAME"
  cp "$ROOT/LICENSE" "$STAGE/LICENSE.txt"
  cp "$ROOT/NOTICE" "$STAGE/NOTICE.txt"
  prune_bundled_helpers

  tar -C "$STAGE" -czf "$ARCHIVE" .
  echo "Packaged:"
  echo "$ARCHIVE"
}

main "$@"
