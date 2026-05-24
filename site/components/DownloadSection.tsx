const releaseBase =
  'https://github.com/drmhse/bumblebee-ui/releases/latest/download';

export function DownloadSection() {
  return (
    <section className="download" id="download" aria-labelledby="download-heading">
      <div>
        <p className="eyebrow">SIGNED RELEASE</p>
        <h2 id="download-heading">Download Bumblebee for macOS.</h2>
        <p>
          Choose the build for your Mac. The DMGs are signed by Developer ID
          Application: Mike Chumba and published from the public GitHub
          release.
        </p>
      </div>
      <div className="download-actions">
        <a className="button primary" href={`${releaseBase}/Bumblebee-1.0.0-1-arm64.dmg`}>
          Apple Silicon DMG
        </a>
        <a className="button secondary" href={`${releaseBase}/Bumblebee-1.0.0-1-x64.dmg`}>
          Intel DMG
        </a>
        <a className="button ghost" href="https://github.com/drmhse/bumblebee-ui">
          Star on GitHub
        </a>
      </div>
    </section>
  );
}
