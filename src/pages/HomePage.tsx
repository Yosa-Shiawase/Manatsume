import { Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { Play, Search, Heart, Download, Headphones } from 'lucide-react';

export default function HomePage() {
  return (
    <div className="min-h-screen bg-[var(--color-bg)] text-[var(--color-text)] font-sans selection:bg-[var(--color-accent)]/30">
      <header className="sticky top-0 z-30 flex items-center justify-between px-5 py-3 border-b border-[var(--color-border)] bg-[var(--color-bg)]/80 backdrop-blur-sm">
        <div className="flex items-center gap-3">
          <a href="/" className="text-lg font-semibold tracking-tight">Manatsume</a>
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
            <Play className="w-4 h-4" />
            Player
          </Link>
        </div>
      </header>

      <section className="max-w-5xl mx-auto px-5 py-12 md:py-20">
        <div className="max-w-2xl">
          <div className="flex gap-3 mb-3">
            <span className="text-xs uppercase tracking-widest text-[var(--color-muted)]">Free music player</span>
            <span className="text-xs px-2 py-0.5 rounded-full bg-[var(--color-accent)]/15 text-[var(--color-accent)]">Installable</span>
          </div>
          <motion.h1
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-4xl md:text-5xl font-semibold leading-tight mb-4"
          >
            Your music,
            <br />
            <span className="text-[var(--color-accent)]">your night.</span>
          </motion.h1>
          <motion.p
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.15 }}
            className="text-sm text-[var(--color-muted)] mb-6 max-w-lg"
          >
            Catalog powered by{' '}
            <a href="https://www.jamendo.com" target="_blank" rel="noopener" className="underline hover:text-[var(--color-text)]">Jamendo</a>{' '}
            under a non-commercial API plan, plus music you add yourself. Each track credits its artist and shows its license.
            In-app licensing details live in{' '}
            <Link to="/licenses" className="underline">Licenses</Link>.
          </motion.p>
          <p className="text-xs text-[var(--color-muted)] mt-3">
            SoundCloud and Free Music Archive are not available as catalog sources in this build; only the Jamendo catalog and your own legal music are supported.
          </p>

          <motion.p
            initial={{ opacity: 0, y: 8 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="text-[var(--color-muted)] mb-8 max-w-lg"
          >
            Manatsume is a free music player with playlists, search, and a calm dark theme you can install in Chrome and use like an app.
          </motion.p>
          <motion.div
            initial={{ opacity: 0, y: 8 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="flex gap-3"
          >
            <Link
              to="/player"
              className="bg-[var(--color-accent)] text-[var(--color-bg)] font-medium px-6 py-3 rounded-full flex items-center gap-2 hover:brightness-110 transition"
            >
              <Play className="w-4 h-4" />
              Start listening
            </Link>
            <Link
              to="/search"
              className="border border-[var(--color-border)] bg-[var(--color-surface)] px-6 py-3 rounded-full hover:border-[var(--color-accent)]/40 transition flex items-center gap-2"
            >
              <Search className="w-4 h-4" />
              Search music
            </Link>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 8 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
            className="flex flex-wrap gap-2 mt-8"
          >
            {['Installable in Chrome', 'Night theme', 'Free music sources', 'Your playlists', 'Search', 'Local files'].map((f) => (
              <span key={f} className="text-xs px-3 py-1.5 rounded-full bg-[var(--color-surface)]/60 text-[var(--color-muted)] border border-[var(--color-border)]">
                {f}
              </span>
            ))}
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 16 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4 }}
            className="relative mt-10 rounded-2xl overflow-hidden aspect-square max-w-md mx-auto border border-[var(--color-border)] bg-[var(--color-surface)] shadow-2xl"
          >
            <img src="https://picsum.photos/seed/manatsume-hero/800/800" alt="mood artwork" className="w-full h-full object-cover" />
            <div className="absolute inset-0 bg-gradient-to-t from-[var(--color-bg)] to-transparent" />
            <div className="absolute bottom-4 left-4 right-4 flex items-center gap-3 bg-[var(--color-surface)]/80 backdrop-blur-sm rounded-xl px-4 py-3">
              <div className="h-10 w-10 rounded overflow-hidden bg-[var(--color-muted)] flex items-center justify-center">
                <span className="text-lg">♫</span>
              </div>
              <div>
                <p className="text-sm font-medium">Midnight Signal</p>
                <p className="text-xs text-[var(--color-muted)]">Long Summer Night</p>
              </div>
            </div>
          </motion.div>

          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.6 }}
            className="mt-10 flex flex-wrap gap-4 text-xs text-[var(--color-muted)]"
          >
            <Link to="/privacy" className="hover:text-[var(--color-text)]">Privacy</Link>
            <Link to="/licenses" className="hover:text-[var(--color-text)]">Licenses</Link>
            <Link to="/sources" className="hover:text-[var(--color-text)]">Sources</Link>
            <a href="https://www.jamendo.com/" target="_blank" rel="noopener" className="hover:text-[var(--color-text)]">Music from Jamendo</a>
            <span>© Manatsume</span>
          </motion.div>
        </div>
      </section>

      <section className="max-w-5xl mx-auto px-5 pb-24">
        <div className="max-w-2xl">
          <motion.h2
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-2xl font-semibold mb-6"
          >
            Why Manatsume
          </motion.h2>
          <div className="grid gap-4 sm:grid-cols-2">
            {[
              { icon: Search, title: 'Search across free music', body: 'Find songs and artists from free music sources and your own library.' },
              { icon: Heart, title: 'Your playlists', body: 'Build playlists that live with your account and travel with you.' },
              { icon: Download, title: 'Own your files', body: 'Add your own music files for playback that stays in your control.' },
              { icon: Headphones, title: 'Player with you', body: 'A player that stays alive across the app, with queue, repeat, and shuffle.' },
            ].map(({ icon: Icon, title, body }) => (
              <motion.div
                key={title}
                initial={{ opacity: 0, y: 12 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.1 }}
                className="rounded-2xl border border-[var(--color-border)] bg-[var(--color-surface)] p-5"
              >
                <div className="flex items-center gap-3 mb-3">
                  <div className="h-9 w-9 rounded-xl bg-[var(--color-accent)]/15 flex items-center justify-center text-[var(--color-accent)]">
                    <Icon className="w-5 h-5" />
                  </div>
                  <h3 className="text-sm font-semibold">{title}</h3>
                </div>
                <p className="text-sm text-[var(--color-muted)] leading-relaxed">{body}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>
    </div>
  );
}
