import { Link } from 'react-router-dom';
import TopNav from '../components/TopNav';

export default function SourcesPage() {
  return (
    <div className="min-h-screen bg-[var(--color-bg)] text-[var(--color-text)] font-sans selection:bg-[var(--color-accent)]/30">
      <TopNav />
      <section className="max-w-3xl mx-auto px-5 py-12">
        <h1 className="text-3xl font-semibold mb-6">Sources</h1>
        <div className="space-y-6 text-sm leading-relaxed text-[var(--color-muted)]">
          <p>
            Manatsume plays music from free sources and from music you add yourself.
          </p>

          <h2 className="text-base font-medium text-[var(--color-text)] mb-2">Jamendo</h2>
          <p>
            The app searches and plays music from the Jamendo catalog through the{' '}
            <a
              href="https://developer.jamendo.com/"
              target="_blank"
              rel="noopener"
              className="underline hover:text-[var(--color-text)]"
            >
              Jamendo API v3.0
            </a>
            . Tracks are streamed from the source URLs the API provides, with the artist credit and license
            shown in-app for each track.
          </p>

          <h2 className="text-base font-medium text-[var(--color-text)] mb-2">Your own music</h2>
          <p>
            You can add your own legal music files and play them in the app. Those files stay on your device
            and are not uploaded anywhere.
          </p>

          <h2 className="text-base font-medium text-[var(--color-text)] mb-2">Not available right now</h2>
          <ul className="list-disc pl-5 space-y-1">
            <li>SoundCloud is not available as a catalog source in this build.</li>
            <li>Free Music Archive is not available as a catalog source in this build.</li>
          </ul>
          <p>
            If a source is not listed here, it is not supported yet. The app only plays music from sources it
            explicitly supports.
          </p>

          <h2 className="text-base font-medium text-[var(--color-text)] mb-2">How playback works</h2>
          <p>
            When you play a track, the app streams it from its source URL through the in-app audio element. If
            a direct stream URL is available, downloads can be offered from that source.
          </p>

          <p className="text-xs text-[var(--color-muted)] border-t border-[var(--color-border)] pt-4">
            This page is informational. Always check the license on the source page for each track before
            reusing it.
          </p>
        </div>

        <footer className="mt-12 border-t border-[var(--color-border)] pt-6 text-xs text-[var(--color-muted)] flex flex-wrap gap-4">
          <Link to="/" className="hover:text-[var(--color-text)]">Home</Link>
          <Link to="/licenses" className="hover:text-[var(--color-text)]">Licenses</Link>
          <Link to="/privacy" className="hover:text-[var(--color-text)]">Privacy</Link>
          <a href="https://www.jamendo.com" target="_blank" rel="noopener" className="hover:text-[var(--color-text)]">Music via Jamendo</a>
          <span>MIT</span>
        </footer>
      </section>
    </div>
  );
}
