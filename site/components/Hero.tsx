import type { CSSProperties } from 'react';

import { BrandMark } from './BrandMark';

const heroScreenshots = [
  {
    src: '/screenshots/dashboard.png',
    srcSet: '/screenshots/dashboard-960.webp 960w, /screenshots/dashboard-1600.webp 1600w',
    title: 'Dashboard',
  },
  {
    src: '/screenshots/inventory.png',
    srcSet: '/screenshots/inventory-960.webp 960w, /screenshots/inventory-1600.webp 1600w',
    title: 'Inventory',
  },
  {
    src: '/screenshots/about.png',
    srcSet: '/screenshots/about-960.webp 960w, /screenshots/about-1600.webp 1600w',
    title: 'About',
  },
];

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
          <p className="eyebrow">LOCAL DESKTOP SCANNER</p>
          <h1>Bumblebee</h1>
          <p className="lede">
            A quiet endpoint inventory app for developer machines. Pick a scan
            profile, verify local roots, run a package scan, and review
            diagnostics and catalog matches without leaving the desktop.
          </p>
          <div className="hero-actions">
            <a className="button primary" href="#download">
              Download
            </a>
            <a className="button secondary" href="https://github.com/drmhse/bumblebee-ui">
              Star on GitHub
            </a>
          </div>
          <dl className="terminal-stats" aria-label="Release status">
            <div>
              <dt>RELEASE</dt>
              <dd>1.0.1</dd>
            </div>
            <div>
              <dt>SIGNING</dt>
              <dd>SIGNED</dd>
            </div>
            <div>
              <dt>ARCH</dt>
              <dd>MAC + LINUX</dd>
            </div>
          </dl>
        </div>

        <div className="hero-visual" aria-label="Bumblebee app preview">
          <div className="screenshot-reel">
            <div className="screenshot-stage">
              {heroScreenshots.map((shot, index) => (
                <figure
                  className="hero-shot"
                  key={shot.title}
                  style={{ '--shot-index': index } as CSSProperties}
                >
                  <picture>
                    <source
                      srcSet={shot.srcSet}
                      sizes="(max-width: 980px) calc(100vw - 24px), 680px"
                      type="image/webp"
                    />
                    <img
                      src={shot.src}
                      alt={`Bumblebee ${shot.title} screen`}
                      width="2688"
                      height="1864"
                    />
                  </picture>
                </figure>
              ))}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
