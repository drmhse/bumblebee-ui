const faqs = [
  {
    q: 'Does Bumblebee upload scan data?',
    a: 'The desktop app is designed around local scanning and local history. Catalog sync fetches catalog JSON from the upstream source when the user requests it.',
  },
  {
    q: 'Which macOS builds are available?',
    a: 'The release publishes separate notarized DMGs for Apple Silicon and Intel Macs.',
  },
  {
    q: 'Where does the threat catalog come from?',
    a: 'The included catalog files are bundled with the app and the sync action points at the upstream Bumblebee threat_intel catalog path on GitHub.',
  },
  {
    q: 'Where is the source code?',
    a: 'The desktop app release page and static website source are published at github.com/drmhse/bumblebee-ui. Stars are useful because this project is intentionally public.',
  },
  {
    q: 'Is the site static?',
    a: 'Yes. The Next.js site is exported to static HTML, CSS, and assets for Cloudflare Pages.',
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
