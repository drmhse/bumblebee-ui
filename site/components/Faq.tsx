const faqs = [
  {
    q: 'Does Bumblebee upload scan data?',
    a: 'The desktop app is designed around local scanning and local history. Catalog sync fetches catalog JSON from the upstream source when the user requests it.',
  },
  {
    q: 'Which builds are available?',
    a: 'The release publishes Apple Silicon and Intel Mac DMGs, plus an early untested Ubuntu/Linux x64 tarball. Issues are welcome.',
  },
  {
    q: 'Where does the threat catalog come from?',
    a: 'The included catalog files are bundled with the app and the sync action points at the upstream Bumblebee threat_intel catalog path on GitHub.',
  },
  {
    q: 'Where is the source code?',
    a: 'The desktop app release page and static website source are published at github.com/drmhse/bumblebee-ui. Stars are useful because this project is intentionally public.',
  },
];

export function Faq() {
  return (
    <section className="section faq" aria-labelledby="faq-heading">
      <div className="section-heading">
        <p className="eyebrow">NOTES</p>
        <h2 id="faq-heading">Operational details.</h2>
      </div>
      <div className="faq-grid">
        {faqs.map((item) => (
          <article className="panel" key={item.q}>
            <h3>{item.q}</h3>
            <p>{item.a}</p>
          </article>
        ))}
      </div>
    </section>
  );
}
