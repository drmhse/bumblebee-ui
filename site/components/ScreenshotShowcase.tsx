const screenshots = [
  {
    src: '/screenshots/dashboard.png',
    srcSet: '/screenshots/dashboard-960.webp 960w, /screenshots/dashboard-1600.webp 1600w',
    title: 'Dashboard',
    text: 'One status surface for findings, diagnostics, scan progress, scope, and inventory composition.',
  },
  {
    src: '/screenshots/inventory.png',
    srcSet: '/screenshots/inventory-960.webp 960w, /screenshots/inventory-1600.webp 1600w',
    title: 'Inventory',
    text: 'Search and filter scanned packages with ecosystem, confidence, source, root, and pagination context.',
  },
  {
    src: '/screenshots/about.png',
    srcSet: '/screenshots/about-960.webp 960w, /screenshots/about-1600.webp 1600w',
    title: 'About',
    text: 'Version, catalog provenance, documentation links, attribution, and repository access in one place.',
  },
];

export function ScreenshotShowcase() {
  return (
    <section className="section" id="screenshots" aria-labelledby="screenshots-heading">
      <div className="section-heading">
        <p className="eyebrow">APP SURFACE</p>
        <h2 id="screenshots-heading">Built for repeated local checks.</h2>
      </div>
      <div className="screenshots">
        {screenshots.map((shot) => (
          <figure className="screenshot-card" key={shot.title}>
            <picture>
              <source
                srcSet={shot.srcSet}
                sizes="(max-width: 720px) calc(100vw - 24px), (max-width: 980px) calc((100vw - 58px) / 2), 690px"
                type="image/webp"
              />
              <img
                src={shot.src}
                alt={`Bumblebee ${shot.title} screen`}
                loading="lazy"
                width="2688"
                height="1864"
              />
            </picture>
            <figcaption>
              <strong>{shot.title}</strong>
              <span>{shot.text}</span>
            </figcaption>
          </figure>
        ))}
      </div>
    </section>
  );
}
