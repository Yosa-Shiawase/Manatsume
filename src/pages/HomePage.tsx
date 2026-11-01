import { Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { Search, Heart, Headphones, Download } from 'lucide-react';
import TopNav from '../components/TopNav';
import { useReducedMotion } from '../hooks/useReducedMotion';

import type { Variants } from 'framer-motion';

function reducedVariants(v: Variants) {
  return useReducedMotion()
    ? { hidden: {}, visible: { opacity: 1 } }
    : v;
}

const FEATURES = [
  {
    icon: Search,
    title: 'Search free music',
    body: 'Find songs and artists from the Jamendo catalog and your own library. Each track shows its artist credit and license.',
  },
  {
    icon: Heart,
    title: 'Your playlists',
    body: 'Build playlists that live with your account and travel with you across devices.',
  },
  {
    icon: Download,
    title: 'Own your files',
    body: 'Add your own music files for playback that stays in your control and on your device.',
  },
  {
    icon: Headphones,
    title: 'Player that stays with you',
    body: 'A single player across the app, with queue, repeat, shuffle, and volume.',
  },
];

export default function HomePage() {
  return (
    <div className="min-h-screen bg-[var(--color-bg)] text-[var(--color-text)] font-sans selection:bg-[var(--color-accent)]/30">
      <TopNav />

      <section className="max-w-5xl mx-auto px-5 pt-14 md:pt-22 pb-12">
        <div className="max-w-2xl">
          <motion.div
            initial="hidden"
            animate="visible"
            variants={reducedVariants({ hidden: { opacity: 0, y: 10 }, visible: { opacity: 1, y: 0 } })}
            className="flex items-center gap-2 mb-4"
          >
            <span className="text-xs uppercase tracking-widest text-[var(--color-muted)]">Free music player</span>
            <span className="text-xs px-2 py-0.5 rounded-full bg-[var(--color-accent)]/15 text-[var(--color-accent)]">Installable</span>
          </motion.div>

          <motion.h1
            initial="hidden"
            animate="visible"
            variants={reducedVariants({ hidden: { opacity: 0, y: 14 }, visible: { opacity: 1, y: 0 } })}
            transition={{ delay: 0.08 }}
            className="text-4xl md:text-5xl font-semibold leading-tight mb-4"
          >
            Your music,
            <br />
            <span className="text-[var(--color-accent)]">your night.</span>
          </motion.h1>

          <motion.p
            initial="hidden"
            animate="visible"
            variants={reducedVariants({ hidden: { opacity: 0, y: 14 }, visible: { opacity: 1, y: 0 } })}
            transition={{ delay: 0.16 }}
            className="text-sm text-[var(--color-muted)] mb-6 max-w-lg leading-relaxed"
          >
            Catalog powered by{' '}
            <a
              href="https://www.jamendo.com"
              target="_blank"
              rel="noopener"
              className="underline hover:text-[var(--color-text)]"
            >
              Jamendo
            </a>{' '}
            under a non-commercial API plan, plus music you add yourself. Each track credits its artist and
            shows its license. In-app licensing details live in{' '}
            <Link to="/licenses" className="underline">Licenses</Link>.
          </motion.p>

          <motion.div
            initial="hidden"
            animate="visible"
            variants={reducedVariants({ hidden: { opacity: 0, y: 10 }, visible: { opacity: 1, y: 0 } })}
            transition={{ delay: 0.24 }}
            className="flex flex-wrap gap-3"
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
            <Link
              to="/library"
              className="border border-[var(--color-border)] bg-[var(--color-surface)] px-6 py-3 rounded-full hover:border-[var(--color-accent)]/40 transition flex items-center gap-2"
            >
              <Heart className="w-4 h-4" />
              Your library
            </Link>
          </motion.div>

          <motion.div
            initial="hidden"
            animate="visible"
            variants={reducedVariants({ hidden: { opacity: 0, y: 8 }, visible: { opacity: 1, y: 0 } })}
            transition={{ delay: 0.3 }}
            className="flex flex-wrap gap-2 mt-8"
          >
            {[
              'Installable in Chrome',
              'Night theme',
              'Free music sources',
              'Your playlists',
              'Search',
              'Your own files',
            ].map((f) => (
              <span
                key={f}
                className="text-xs px-3 py-1.5 rounded-full bg-[var(--color-surface)]/60 text-[var(--color-muted)] border border-[var(--color-border)]"
              >
                {f}
              </span>
            ))}
          </motion.div>

          <motion.div
            initial="hidden"
            animate="visible"
            variants={reducedVariants({ hidden: { opacity: 0, y: 16 }, visible: { opacity: 1, y: 0 } })}
            transition={{ delay: 0.38 }}
            className="relative mt-12 rounded-2xl overflow-hidden aspect-[4/3] max-w-lg mx-auto border border-[var(--color-border)] bg-[var(--color-surface)] shadow-2xl"
          >
            <div className="absolute inset-0 bg-gradient-to-br from-[var(--color-accent)]/10 via-transparent to-transparent" />
            <div className="absolute inset-0 flex items-center justify-center">
              <svg
                className="w-40 h-40 opacity-70"
                viewBox="0 0 64 64"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
                aria-hidden="true"
                style={{ transform: 'scale(3.2)', transformOrigin: 'center' }}
              >
                <rect width="64" height="64" rx="14" fill="var(--color-bg)" />
                <g fill="none" stroke="var(--color-fox-ear)" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M18 26 L26 16 L30 26" />
                  <path d="M46 26 L38 16 L34 26" />
                </g>
                <path d="M14 34 Q24 22 32 22 Q40 22 50 34" fill="none" stroke="var(--color-fox-fur)" strokeWidth="2.6" strokeLinecap="round" />
                <circle cx="24" cy="32" r="1.6" fill="var(--color-fox-fur)" />
                <circle cx="40" cy="32" r="1.6" fill="var(--color-fox-fur)" />
                <path d="M27 36 L37 36" stroke="var(--color-fox-eye)" strokeWidth="1.6" strokeLinecap="round" />
                <path d="M42 38 Q46 42 44 47" fill="none" stroke="var(--color-fox-ear)" strokeWidth="2" strokeLinecap="round" />
              </svg>
            </div>
            <div className="absolute bottom-4 left-4 right-4 flex items-center gap-3 bg-[var(--color-surface)]/80 backdrop-blur-sm rounded-xl px-4 py-3 border border-[var(--color-border)]">
              <div className="h-10 w-10 rounded overflow-hidden bg-[var(--color-muted)]/30 flex items-center justify-center text-lg">
                ♫
              </div>
              <div>
                <p className="text-sm font-medium">Long Summer Night</p>
                <p className="text-xs text-[var(--color-muted)]">via Jamendo</p>
              </div>
            </div>
          </motion.div>

          <motion.div
            initial="hidden"
            animate="visible"
            variants={reducedVariants({ hidden: { opacity: 0 }, visible: { opacity: 1 } })}
            transition={{ delay: 0.5 }}
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
            initial="hidden"
            animate="visible"
            variants={reducedVariants({ hidden: { opacity: 0, y: 12 }, visible: { opacity: 1, y: 0 } })}
            className="text-2xl font-semibold mb-6"
          >
            Why Manatsume
          </motion.h2>
          <div className="grid gap-4 sm:grid-cols-2">              {FEATURES.map(({ icon: Icon, title, body }) => (
                <motion.div
                  key={title}
                  initial="hidden"
                  animate="visible"
                  variants={reducedVariants({ hidden: { opacity: 0, y: 12 }, visible: { opacity: 1, y: 0 } })}
                  transition={{ delay: 0.08 }}
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

function Play({ className }: { className?: string }) {
  return (
    <svg className={className ?? ''} viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
      <polygon points="5 3 19 12 5 21 5 3" />
    </svg>
  );
}
