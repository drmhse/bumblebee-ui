#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(cd "$ROOT/.." && pwd)"
BUMP="${1:-patch}"

current="$(awk '/^version:/ { print $2; exit }' "$ROOT/pubspec.yaml")"
build_name="${current%%+*}"
build_number="${current#*+}"
if [[ "$build_number" == "$current" ]]; then
  build_number=0
fi

IFS=. read -r major minor patch <<<"$build_name"
major="${major:-0}"
minor="${minor:-0}"
patch="${patch:-0}"

case "$BUMP" in
  major)
    major=$((major + 1))
    minor=0
    patch=0
    ;;
  minor)
    minor=$((minor + 1))
    patch=0
    ;;
  patch)
    patch=$((patch + 1))
    ;;
  build)
    ;;
  *)
    echo "Usage: $0 [major|minor|patch|build]" >&2
    exit 2
    ;;
esac

build_number=$((build_number + 1))
next_name="$major.$minor.$patch"
next_version="$next_name+$build_number"
dmg_version="$next_name-$build_number"

perl -0pi -e "s/^version: .*/version: $next_version/m" "$ROOT/pubspec.yaml"
cat >"$ROOT/lib/build_info.dart" <<EOF
class BuildInfo {
  static const version = '$next_version';
  static const buildName = '$next_name';
  static const buildNumber = $build_number;
}
EOF

if [[ -f "$REPO_ROOT/README.md" ]]; then
  perl -0pi -e "s/Bumblebee-[0-9]+\\.[0-9]+\\.[0-9]+-[0-9]+-arm64\\.dmg/Bumblebee-$dmg_version-arm64.dmg/g; s/Bumblebee-[0-9]+\\.[0-9]+\\.[0-9]+-[0-9]+-x64\\.dmg/Bumblebee-$dmg_version-x64.dmg/g" "$REPO_ROOT/README.md"
  perl -0pi -e "s/Bumblebee-[0-9]+\\.[0-9]+\\.[0-9]+-[0-9]+-linux-x64\\.tar\\.gz/Bumblebee-$dmg_version-linux-x64.tar.gz/g" "$REPO_ROOT/README.md"
fi

if [[ -d "$REPO_ROOT/site" ]]; then
  if [[ -f "$REPO_ROOT/site/package.json" ]]; then
    perl -0pi -e "s/\"version\":\\s*\"[^\"]+\"/\"version\": \"$next_name\"/" "$REPO_ROOT/site/package.json"
  fi
  for file in "$REPO_ROOT/site/app/page.tsx" "$REPO_ROOT/site/components/Hero.tsx" "$REPO_ROOT/site/components/DownloadSection.tsx"; do
    [[ -f "$file" ]] || continue
    perl -0pi -e "s/softwareVersion:\\s*'[^']+'/softwareVersion: '$next_name'/g; s/<dd>[0-9]+\\.[0-9]+\\.[0-9]+<\\/dd>/<dd>$next_name<\\/dd>/g; s/Bumblebee-[0-9]+\\.[0-9]+\\.[0-9]+-[0-9]+-arm64\\.dmg/Bumblebee-$dmg_version-arm64.dmg/g; s/Bumblebee-[0-9]+\\.[0-9]+\\.[0-9]+-[0-9]+-x64\\.dmg/Bumblebee-$dmg_version-x64.dmg/g; s/Bumblebee-[0-9]+\\.[0-9]+\\.[0-9]+-[0-9]+-linux-x64\\.tar\\.gz/Bumblebee-$dmg_version-linux-x64.tar.gz/g" "$file"
  done
fi

echo "$next_version"
