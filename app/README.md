# Bumblebee Desktop

Flutter desktop wrapper for the `perplexityai/bumblebee` endpoint inventory scanner.

## What It Does

- Runs the Bumblebee CLI as a local helper process.
- Parses package, finding, diagnostic, and scan summary NDJSON records.
- Shows Dashboard, Inventory, Threat Intelligence, and Scan History views.
- Keeps local scan history in the platform application-support directory.
- Supports multiple visual themes, with the dark Command theme as the primary design.
- Bundles upstream threat catalogs and can sync catalog JSON files from GitHub.

## Package Identity

The desktop app identifier is `bumblebee.drmhse.com`.

## Helper Binaries

The app can find Bumblebee in this order:

1. `BUMBLEBEE_BIN`
2. A binary next to the app or in the development parent directory
3. A bundled Flutter asset extracted into app support
4. `bumblebee` on `PATH`

This checkout bundles helper binaries for macOS ARM64, macOS x64, Linux x64, and Windows x64. To rebuild them from upstream, run:

```sh
./tool/build_bumblebee_helpers.sh
```

Go can cross-compile the Bumblebee helper for Linux and Windows because the scanner is a static Go CLI. Flutter desktop builds still need the relevant host toolchain for each app shell: macOS on macOS/Xcode, Linux on a Linux build host with GTK tooling, and Windows on Windows/Visual Studio.

## Threat Catalogs

The upstream repository maintains JSON exposure catalogs under `threat_intel/`. The app seeds local catalogs from bundled assets, then `Sync from upstream` downloads the known catalog files from:

```text
https://raw.githubusercontent.com/perplexityai/bumblebee/main/threat_intel/
```

Bumblebee v0.1 matches exact ecosystem, normalized package name, and version. Findings are package-presence matches, not EDR process, network, or file-hash IOCs.
