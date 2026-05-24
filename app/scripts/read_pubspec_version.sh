#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
awk '/^version:/ { print $2; exit }' "$ROOT/pubspec.yaml" | tr '+' '-'
