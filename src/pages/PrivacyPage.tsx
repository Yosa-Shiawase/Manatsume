import { Link } from 'react-router-dom';

export default function PrivacyPage() {
  return (
    <div className="min-h-screen bg-[var(--color-bg)] text-[var(--color-text)] font-sans selection:bg-[var(--color-accent)]/30">
      <header className="sticky top-0 z-30 flex items-center justify-between px-5 py-3 border-b border-[var(--color-border)] bg-[var(--color-bg)]/80 backdrop-blur-sm">
        <div className="flex items-center gap-3">
          <Link to="/" className="text-lg font-semibold tracking-tight">Manatsume</Link>
          <nav className="hidden md:flex items-center gap-4 text-sm text-[var(--color-muted)] ml-6">
            <Link to="/" className="hover:text-[var(--color-text)]">Home</Link>
            <Link to="/search" className="hover:text-[var(--color-text)]">Search</Link>
            <Link to="/library" className="hover:text-[var(--color-text)]">Library</Link>
          </nav>
        </div>
        <div className="flex items-center gap-2">
          <Link
            to="/player"
            className="px-4 py-2 rounded-full text-sm border border-[var(--color-border)] bg-[var(--color-surface)] hover:border-[var(--color-accent)]/50 transition flex items-center gap-2"
          >
            <svg className="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round">
              <polygon points="5 3 19 12 5 21 5 3" />
            </svg>
            Player
          </Link>
        </div>
      </header>

      <section className="max-w-3xl mx-auto px-5 py-12">
        <h1 className="text-3xl font-semibold mb-6">Privacy</h1>
        <div className="space-y-6 text-sm leading-relaxed text-[var(--color-muted)]">
          <p>
            Manatsume is a music player. This page explains what the app stores and why.
          </p>

          <h2 className="text-base font-medium text-[var(--color-text)] mb-2">What is stored on your device</h2>
          <p>
            When you are signed in, the app keeps your playlists, liked tracks, and queue on your device so
            they are available while you use the app. This local data is keyed to your account and is meant
            to help you pick up where you left off.
          </p>

          <h2 className="text-base font-medium text-[var(--color-text)] mb-2">Cached covers and audio</h2>
          <p>
            To make playback faster and reduce repeated network requests, the app can temporarily cache
            album artwork and audio it streams. These caches live on your device and are managed locally.
          </p>

          <h2 className="text-base font-medium text-[var(--color-text)] mb-2">Music sources</h2>
          <p>
            Search uses the Jamendo catalog through their public API. Songs you play are streamed from the
            source links that catalog provides. The app does not upload your personal music files anywhere.
          </p>

          <h2 className="text-base font-medium text-[var(--color-text)] mb-2">Your music files</h2>
          <p>
            Any music you add yourself remains on your device. The app plays what you provide and does not
            send those files to any server.
          </p>

          <h2 className="text-base font-medium text-[var(--color-text)] mb-2">Data minimization</h2>
          <p>
            The app only keeps what it needs so the player, playlists, and queue work as expected. You can
            clear local caches and data through the app settings.
          </p>

          <p className="text-xs text-[var(--color-muted)] border-t border-[var(--color-border)] pt-4">
            This page is informational and is not legal advice. If anything here needs to change, update the
            app and this page together.
          </p>
        </div>

        <footer className="mt-12 border-t border-[var(--color-border)] pt-6 text-xs text-[var(--color-muted)] flex flex-wrap gap-4">
          <Link to="/" className="hover:text-[var(--color-text)]">Home</Link>
          <Link to="/licenses" className="hover:text-[var(--color-text)]">Licenses</Link>
          <Link to="/sources" className="hover:text-[var(--color-text)]">Sources</Link>
          <span>MIT</span>
        </footer>
      </section>
    </div>
  );
}
