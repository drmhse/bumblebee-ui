#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="${ROOT_DIR}/.build/bumblebee-upstream"
REPO_URL="${BUMBLEBEE_REPO_URL:-https://github.com/perplexityai/bumblebee.git}"
REF="${BUMBLEBEE_REF:-v0.1.1}"
SIGN_IDENTITY="${SIGN_IDENTITY:-}"

if [[ ! -d "${WORK_DIR}/.git" ]]; then
  rm -rf "${WORK_DIR}"
  git clone --depth 1 --branch "${REF}" "${REPO_URL}" "${WORK_DIR}"
else
  git -C "${WORK_DIR}" fetch --depth 1 origin "${REF}"
  git -C "${WORK_DIR}" checkout FETCH_HEAD
fi

build_one() {
  local goos="$1"
  local goarch="$2"
  local asset_dir="$3"
  local output_name="bumblebee"
  if [[ "${goos}" == "windows" ]]; then
    output_name="bumblebee.exe"
  fi
  mkdir -p "${ROOT_DIR}/assets/bin/${asset_dir}"
  (
    cd "${WORK_DIR}"
    GOOS="${goos}" GOARCH="${goarch}" CGO_ENABLED=0 \
      go build -trimpath -ldflags "-s -w" \
      -o "${ROOT_DIR}/assets/bin/${asset_dir}/${output_name}" ./cmd/bumblebee
  )
  if [[ "${goos}" == "darwin" && -n "${SIGN_IDENTITY}" ]]; then
    codesign --force --timestamp --options runtime \
      --sign "${SIGN_IDENTITY}" \
      "${ROOT_DIR}/assets/bin/${asset_dir}/${output_name}"
  fi
}

build_one darwin arm64 macos-arm64
build_one darwin amd64 macos-x64
build_one linux amd64 linux-x64
build_one windows amd64 windows-x64

echo "Bumblebee helper binaries written to assets/bin/."
