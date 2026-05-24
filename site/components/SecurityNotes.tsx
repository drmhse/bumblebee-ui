export function SecurityNotes() {
  return (
    <section className="section split" id="security" aria-labelledby="security-heading">
      <div>
        <p className="eyebrow">THREAT CATALOG</p>
        <h2 id="security-heading">Catalogs are explicit inputs.</h2>
        <p>
          Bumblebee ships with JSON catalog files under the app assets and can
          sync those files from the upstream Bumblebee threat-intel repository.
          The app shows catalog names, entry counts, and local modification
          times so users can tell which data informed a scan.
        </p>
      </div>
      <div className="terminal-panel">
        <div><span>mini-shai-hulud.json</span><b>entries listed</b></div>
        <div><span>gemstuffer.json</span><b>entries listed</b></div>
        <div><span>node-ipc-credential-stealer.json</span><b>entries listed</b></div>
        <div><span>nx-console-vscode-2026-05-18.json</span><b>entries listed</b></div>
      </div>
    </section>
  );
}
