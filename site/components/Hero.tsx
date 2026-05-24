import { BrandMark } from './BrandMark';

export function Hero() {
  return (
    <section className="hero">
      <nav className="nav" aria-label="Primary">
        <BrandMark compact />
        <div className="nav-links">
          <a href="#screenshots">Screenshots</a>
          <a href="#download">Download</a>
          <a href="https://github.com/drmhse/bumblebee-ui">GitHub stars</a>
        </div>
      </nav>

      <div className="hero-grid">
        <div className="hero-copy">
          <p className="eyebrow">LOCAL MACOS SCANNER</p>
          <h1>Bumblebee</h1>
          <p className="lede">
            A quiet endpoint inventory app for developer machines. Pick a scan
            profile, verify local roots, run a package scan, and review
            diagnostics and catalog matches without leaving the desktop.
          </p>
          <div className="hero-actions">
            <a className="button primary" href="#download">
              Download for macOS
            </a>
            <a className="button secondary" href="https://github.com/drmhse/bumblebee-ui">
              Star on GitHub
            </a>
          </div>
          <dl className="terminal-stats" aria-label="Release status">
            <div>
              <dt>RELEASE</dt>
              <dd>1.0.0</dd>
            </div>
            <div>
              <dt>SIGNING</dt>
              <dd>SIGNED</dd>
            </div>
            <div>
              <dt>ARCH</dt>
              <dd>ARM64 + X64</dd>
            </div>
          </dl>
        </div>

        <div className="hero-visual" aria-label="Bumblebee app preview">
          <div className="window">
            <div className="window-bar">
              <span />
              <span />
              <span />
              <strong>Bumblebee</strong>
            </div>
            <div className="app-frame">
              <aside>
                <BrandMark />
                <b>DASHBOARD</b>
                <span>INVENTORY</span>
                <span>THREAT INTEL</span>
                <span>HISTORY</span>
              </aside>
              <div className="app-main">
                <div className="app-top">
                  <span>BASELINE</span>
                  <button>RUN SCAN</button>
                </div>
                <div className="scan-card pulse-card">
                  <p>NO EXPOSURES DETECTED</p>
                  <strong>103543 package records checked. Status: complete.</strong>
                </div>
                <div className="progress-card">
                  <div className="progress-head">
                    <span>SCAN PROGRESS</span>
                    <b>COMPLETE</b>
                  </div>
                  <div className="progress-line" />
                  <div className="progress-grid">
                    <span>PACKAGES<br /><b>103543</b></span>
                    <span>FINDINGS<br /><b>0</b></span>
                    <span>DIAGNOSTICS<br /><b>8</b></span>
                    <span>FILES<br /><b>2030886</b></span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
