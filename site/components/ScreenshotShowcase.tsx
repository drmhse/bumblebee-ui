const screenshots = [
  {
    src: '/screenshots/dashboard.png',
    title: 'Dashboard',
    text: 'One status surface for findings, diagnostics, scan progress, scope, and inventory composition.',
  },
  {
    src: '/screenshots/diagnostics.png',
    title: 'Diagnostics',
    text: 'Warnings remain inspectable so configuration issues are not reduced to a single count.',
  },
  {
    src: '/screenshots/about.png',
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
            <img src={shot.src} alt={`Bumblebee ${shot.title} screen`} />
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
