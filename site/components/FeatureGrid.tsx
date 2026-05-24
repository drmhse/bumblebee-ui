const features = [
  {
    title: 'Verified scan scope',
    text: 'Directory selection resolves to concrete roots before scan execution, so the visible scope matches what the scanner uses.',
  },
  {
    title: 'Exact scan progress',
    text: 'Package records, findings, diagnostics, files considered, duration, and completion state are shown from the scan stream.',
  },
  {
    title: 'Diagnostics visibility',
    text: 'Warnings from malformed local configs are surfaced directly instead of hiding in a background log.',
  },
  {
    title: 'Catalog review',
    text: 'Threat catalog files are listed with entry counts and update state, with upstream sync available inside the app.',
  },
];

export function FeatureGrid() {
  return (
    <section className="section feature-band" aria-labelledby="features-heading">
      <div className="section-heading">
        <p className="eyebrow">WHAT IT SHOWS</p>
        <h2 id="features-heading">Inventory without blind spots.</h2>
      </div>
      <div className="feature-grid">
        {features.map((feature) => (
          <article className="panel" key={feature.title}>
            <span className="panel-index">0{features.indexOf(feature) + 1}</span>
            <h3>{feature.title}</h3>
            <p>{feature.text}</p>
          </article>
        ))}
      </div>
    </section>
  );
}
